{
  description = "A flake providing Darwin modules for MCP servers";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    darwin,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages = {
          default = pkgs.hello; # A placeholder default package
        };
      }
    )
    // {
      # Darwin module that can be added to darwinConfigurations
      darwinModules.default = {
        config,
        lib,
        pkgs,
        ...
      }: let
        cfg = config.mcp-servers;

        jsonFormat = pkgs.formats.json {};

        # Platform-specific config paths
        configDir = client:
          if pkgs.stdenv.hostPlatform.isDarwin
          then
            if client == "claude-desktop"
            then "Library/Application Support/Claude"
            else if client == "cursor"
            then ".cursor"
            else throw "Unsupported client: ${client}"
          else throw "Only Darwin is supported";

        configFile = client:
          if client == "claude-desktop"
          then "claude_desktop_config.json"
          else if client == "cursor"
          then "mcp.json"
          else throw "Unsupported client: ${client}";

        # Full path to config file
        configPath = client: "${configDir client}/${configFile client}";

        # List of all supported clients
        supportedClients = ["claude-desktop" "cursor"];

        # Generate the configuration
        makeConfig = {
          mcpServers = lib.mkMerge [
            # Always create an empty mcpServers object
            {}
            # Add GitHub config only if enabled
            (lib.mkIf cfg.github.enable {
              github = {
                command = "npx";
                args = [
                  "-y"
                  "@modelcontextprotocol/server-github"
                ];
                env = {
                  GITHUB_PERSONAL_ACCESS_TOKEN = cfg.github.access-token;
                };
              };
            })
            # Add other servers here in the future with their own conditions
          ];
        };
      in {
        options.mcp-servers = {
          github = {
            enable = lib.mkEnableOption "GitHub MCP server";

            access-token = lib.mkOption {
              type = lib.types.str;
              description = "GitHub personal access token for the MCP server";
              example = "ghp_xxxxxxxxxxxxxxxxxxxx";
            };
          };
        };

        config = {
          system.activationScripts.mcp-servers.text = ''
            #!${pkgs.bash}/bin/bash
            echo "Configuring MCP servers"
            echo "GitHub MCP server is ${
              if cfg.github.enable
              then "enabled"
              else "disabled"
            }"
          '';

          # Always create config files for all supported clients
          home.file = lib.mkMerge (map (client: {
              "${configPath client}".source =
                jsonFormat.generate
                "mcp-${client}-config"
                makeConfig;
            })
            supportedClients);
        };
      };
    };
}
