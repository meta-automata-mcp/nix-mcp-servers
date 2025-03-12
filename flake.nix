{
  description = "A nix flake for configuring Model Context Protocol (MCP) servers across supported AI assistant clients.";

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

        # Helper function to write config to a JSON file
        writeClientConfig = client: configData: let
          configPath =
            if client == "claude-desktop"
            then "$HOME/Library/Application Support/Claude/claude_desktop_config.json"
            else if client == "cursor"
            then "$HOME/.cursor/mcp.json"
            else throw "Unsupported client: ${client}";

          configJson = builtins.toJSON configData;
        in ''
          mkdir -p "$(dirname "${configPath}")"
          echo '${configJson}' > "${configPath}"
        '';
      in {
        options.mcp-servers = {
          clients = lib.mkOption {
            type = lib.types.listOf (lib.types.enum ["claude-desktop" "cursor"]);
            default = [];
            description = "List of MCP clients to configure";
            example = ["claude-desktop" "cursor"];
          };

          github = {
            enable = lib.mkEnableOption "GitHub MCP server";

            access-token = lib.mkOption {
              type = lib.types.str;
              description = "GitHub personal access token for the MCP server";
              example = "ghp_xxxxxxxxxxxxxxxxxxxx";
            };
          };
        };

        config = lib.mkIf (cfg.clients
          != []
          && (
            cfg.github.enable
          )) {
          system.activationScripts.mcp-servers = {
            text = ''
              # MCP Servers Configuration
              ${lib.concatMapStringsSep "\n" (
                  client: let
                    configData = {
                      mcpServers = lib.filterAttrs (_: v: v != null) {
                        github =
                          if cfg.github.enable
                          then {
                            command = "npx";
                            args = [
                              "-y"
                              "@modelcontextprotocol/server-github"
                            ];
                            env = {
                              GITHUB_PERSONAL_ACCESS_TOKEN = cfg.github.access-token;
                            };
                          }
                          else null;
                      };
                    };
                  in
                    writeClientConfig client configData
                )
                cfg.clients}
            '';
            supportsDryActivation = false;
          };
        };
      };
    };
}
