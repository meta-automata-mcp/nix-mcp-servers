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

        # Path validation and normalization utilities
        pathUtils = {
          # Expand ~ to $HOME
          expandHome = path:
            if lib.hasPrefix "~" path
            then "\${HOME}${lib.removePrefix "~" path}"
            else path;

          # Normalize path by removing trailing slashes and duplicate slashes
          normalizePath = path:
            builtins.replaceStrings ["//" "///" "////" "/////" "//////"] ["/"]
            (lib.removeSuffix "/" path);

          # Validate a single path
          validatePath = path: {
            assertion = true; # Path existence will be checked at runtime
            message = "Path validation will be performed at runtime: ${path}";
          };
        };

        # Common types and utilities
        serverTypes = {
          github = {
            name = "github";
            requiredOptions = ["access-token"];
            makeConfig = config: {
              command = "npx";
              args = [
                "-y"
                "@modelcontextprotocol/server-github"
              ];
              env = {
                GITHUB_PERSONAL_ACCESS_TOKEN = config.access-token;
              };
            };
          };

          gitlab = {
            name = "gitlab";
            requiredOptions = ["access-token"];
            validateConfig = config:
              lib.optional (config ? api-url) {
                assertion = lib.hasPrefix "https://" config.api-url;
                message = "GitLab API URL must start with https://";
              };
            makeConfig = config: {
              command = "npx";
              args = [
                "-y"
                "@modelcontextprotocol/server-gitlab"
              ];
              env =
                {
                  GITLAB_PERSONAL_ACCESS_TOKEN = config.access-token;
                }
                // lib.optionalAttrs (config ? api-url) {
                  GITLAB_API_URL = config.api-url;
                };
            };
          };

          filesystem = {
            name = "filesystem";
            requiredOptions = ["allowed-paths"];
            validateConfig = config:
              map pathUtils.validatePath config.allowed-paths;
            makeConfig = config: {
              command = "npx";
              args =
                [
                  "-y"
                  "@modelcontextprotocol/server-filesystem"
                ]
                ++ (map (p: pathUtils.normalizePath (pathUtils.expandHome p)) config.allowed-paths);
            };
          };
        };

        # Client type definitions
        clientTypes = {
          "claude-desktop" = {
            name = "claude-desktop";
            configDir = "Library/Application Support/Claude";
            configFile = "claude_desktop_config.json";
            validatePlatform = system: system == "darwin";
          };
          "cursor" = {
            name = "cursor";
            configDir = ".cursor";
            configFile = "mcp.json";
            validatePlatform = system: system == "darwin";
          };
        };

        # Get supported clients based on platform
        supportedClients =
          lib.filterAttrs
          (name: client: client.validatePlatform pkgs.stdenv.hostPlatform.system)
          clientTypes;

        # Get config path for a client
        configPath = client: let
          clientType = clientTypes.${client} or (throw "Unsupported client: ${client}");
        in "${clientType.configDir}/${clientType.configFile}";

        # Validate client configuration
        validateClient = client:
          if ! clientTypes ? ${client}
          then throw "Unsupported client: ${client}"
          else if ! clientTypes.${client}.validatePlatform pkgs.stdenv.hostPlatform.system
          then throw "Client ${client} is not supported on ${pkgs.stdenv.hostPlatform.system}"
          else true;

        # Validate server configuration
        validateServer = serverType: serverConfig: let
          missingOptions =
            lib.filter
            (opt: !builtins.hasAttr opt serverConfig)
            serverTypes.${serverType}.requiredOptions;

          # Run server-specific validation if it exists
          serverValidation =
            if serverTypes.${serverType} ? validateConfig
            then serverTypes.${serverType}.validateConfig serverConfig
            else [];
        in
          if builtins.length missingOptions > 0
          then throw "Missing required options for ${serverType}: ${toString missingOptions}"
          else serverConfig;

        # Generate the configuration
        makeConfig = {
          mcpServers = lib.mkMerge ([
              # Always create an empty mcpServers object
              {}
            ]
            ++ lib.mapAttrsToList (
              name: serverType:
                lib.mkIf (builtins.hasAttr name cfg && cfg.${name}.enable) {
                  ${name} = serverType.makeConfig (validateServer name cfg.${name});
                }
            )
            serverTypes);
        };
      in {
        options.mcp-servers = lib.mkOption {
          type = with lib.types;
            attrsOf (submodule ({name, ...}: {
              options = {
                enable = lib.mkEnableOption "MCP server ${name}";
                access-token = lib.mkOption {
                  type = str;
                  description = "Access token for the ${name} MCP server";
                  example = "xxxxxxxxxxxxxxxxxxxx";
                  default = "";
                };
                api-url = lib.mkOption {
                  type = str;
                  description = "API URL for the ${name} MCP server (if applicable)";
                  example = "https://gitlab.com/api/v4";
                  default = "";
                };
                allowed-paths = lib.mkOption {
                  type = listOf str;
                  description = "List of filesystem paths to allow access to";
                  example = ["/Users/username/Desktop" "/path/to/other/allowed/dir"];
                  default = [];
                };
              };
            }));
          default = {};
          description = "Configuration for MCP servers";
        };

        config = {
          assertions =
            [
              {
                assertion =
                  builtins.all (client: clientTypes ? ${client} && clientTypes.${client}.validatePlatform pkgs.stdenv.hostPlatform.system)
                  (builtins.attrNames supportedClients);
                message = "One or more configured clients are not supported on the current platform";
              }
            ]
            ++ lib.flatten (lib.mapAttrsToList (
                name: server:
                  if server.enable && serverTypes.${name} ? validateConfig
                  then serverTypes.${name}.validateConfig server
                  else []
              )
              cfg);

          system.activationScripts.mcp-servers.text = ''
            #!${pkgs.bash}/bin/bash

            # Function to validate path
            validate_path() {
              local path="$1"
              # Expand home directory if path starts with ~
              if [[ "$path" == "~"* ]]; then
                path="$HOME''${path#\~}"
              fi

              # Check if path exists
              if [[ ! -e "$path" ]]; then
                echo "Error: Path does not exist: $path"
                return 1
              fi

              # Check if we have read access
              if [[ ! -r "$path" ]]; then
                echo "Error: No read permission for path: $path"
                return 1
              fi

              return 0
            }

            echo "Configuring MCP servers"
            ${lib.concatStringsSep "\n" (lib.mapAttrsToList (
                name: server: let
                  validatePaths =
                    if name == "filesystem" && server.enable
                    then ''
                      echo "Validating paths for filesystem server..."
                      ${lib.concatMapStrings (path: ''
                          if ! validate_path "${pathUtils.expandHome path}"; then
                            echo "Path validation failed for filesystem server"
                            exit 1
                          fi
                        '')
                        server.allowed-paths}
                      echo "All paths validated successfully"
                    ''
                    else "";
                in ''
                  echo '${name} MCP server is ${
                    if server.enable
                    then "enabled"
                    else "disabled"
                  }'
                  ${validatePaths}
                ''
              )
              cfg)}
          '';

          # Always create config files for all supported clients
          home.file = lib.mkMerge (lib.mapAttrsToList (name: client: {
              "${configPath name}".source =
                jsonFormat.generate
                "mcp-${name}-config"
                makeConfig;
            })
            supportedClients);
        };
      };
    };
}
