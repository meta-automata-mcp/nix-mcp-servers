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
          echo '${configJson}' > ${configPath}
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
            text = let
              # Define the configuration as a Nix attribute set
              commonConfig = {
                mcpServers = {
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
                };
              };

              # Convert to JSON once
              configJson = builtins.toJSON commonConfig;
            in ''
              #!/bin/bash
              # MCP Servers Configuration
              echo "Configuring MCP servers for clients: ${builtins.concatStringsSep ", " cfg.clients}"

              ${lib.concatMapStringsSep "\n" (client: ''
                  if [[ "${client}" == "claude-desktop" ]]; then
                    CLAUDE_CONFIG_DIR="$HOME/Library/Application Support/Claude"
                    CLAUDE_CONFIG_FILE="$CLAUDE_CONFIG_DIR/claude_desktop_config.json"
                    echo "Setting up Claude Desktop config at $CLAUDE_CONFIG_FILE"
                    mkdir -p "$CLAUDE_CONFIG_DIR"
                    echo '${configJson}' > "$CLAUDE_CONFIG_FILE"
                    echo "Claude Desktop config created"
                  elif [[ "${client}" == "cursor" ]]; then
                    CURSOR_CONFIG_DIR="$HOME/.cursor"
                    CURSOR_CONFIG_FILE="$CURSOR_CONFIG_DIR/mcp.json"
                    echo "Setting up Cursor config at $CURSOR_CONFIG_FILE"
                    mkdir -p "$CURSOR_CONFIG_DIR"
                    echo '${configJson}' > "$CURSOR_CONFIG_FILE"
                    echo "Cursor config created"
                  fi
                '')
                cfg.clients}
            '';
            supportsDryActivation = false;
          };
        };
      };
    };
}
