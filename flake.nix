{
  description = "MCP server configuration management for various clients";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    # Home-manager integration
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Darwin integration
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    home-manager,
    darwin,
    ...
  }: let
    # Common library of functions used across modules
    lib = import ./lib {
      inherit (nixpkgs) lib;
    };

    # Supported MCP server types
    supportedServers = [
      "filesystem"
    ];

    # Supported client types
    supportedClients = [
      "claude_desktop"
    ];

    # Platform-aware default config paths
    defaultConfigPath = clientType: system: let
      isDarwin = builtins.match ".*darwin" system != null;
      darwinBase = "~/Library/Application Support";
      linuxBase = "~/.config";
    in
      if isDarwin
      then
        {
          # macOS paths
          "claude_desktop" = "${darwinBase}/Claude/mcp-config.json";
        }
        .${clientType}
        or "${linuxBase}/mcp/${clientType}-config.json"
      else
        {
          # Linux paths
          "claude_desktop" = "${linuxBase}/claude-desktop/mcp-config.json";
        }
        .${clientType}
        or "${linuxBase}/mcp/${clientType}-config.json";

    # Common module for defining options (shared between NixOS, Darwin and home-manager)
    mkCommonModule = {isHomeManager ? false}: {
      config,
      lib,
      pkgs,
      ...
    }: let
      cfg = config.services.mcp-clients;
      system = pkgs.stdenv.hostPlatform.system;

      # Server submodule definition
      serverModule = {
        name,
        config,
        ...
      }: {
        options = {
          enable = lib.mkEnableOption "this MCP server";

          name = lib.mkOption {
            type = lib.types.str;
            default = name;
            description = "User-friendly name for this server";
          };

          type = lib.mkOption {
            type = lib.types.enum supportedServers;
            default = name;
            description = "Type of MCP server";
          };

          baseUrl = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Base URL for the API (optional)";
          };

          path = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "File system path for filesystem server type. This should point to a directory containing model files or a specific model file.";
          };

          credentials = lib.mkOption {
            type = lib.types.submodule {
              options = {
                apiKey = lib.mkOption {
                  type = lib.types.str;
                  description = "API key for authentication";
                };
                # Add other credential fields as needed
              };
            };
            description = "Credentials for this MCP server";
          };
        };
      };

      # Client submodule definition
      clientModule = {
        name,
        config,
        ...
      }: {
        options = {
          enable = lib.mkEnableOption "this MCP client";

          clientType = lib.mkOption {
            type = lib.types.enum supportedClients;
            default = name;
            description = "Type of MCP client";
          };

          configPath = lib.mkOption {
            type = lib.types.str;
            default = defaultConfigPath config.clientType system;
            description = "Path to the client configuration file";
          };

          servers = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = builtins.attrNames (lib.filterAttrs (n: v: v.enable) cfg.servers);
            description = "List of MCP servers to use with this client";
          };
        };
      };

      # Function to generate client configuration
      mkClientConfig = clientName: clientConfig: let
        # Get only enabled servers that this client wants to use
        relevantServers =
          builtins.filter
          (server: builtins.elem server.name clientConfig.servers)
          (lib.mapAttrsToList (name: server: server // {inherit name;})
            (lib.filterAttrs (n: v: v.enable) cfg.servers));

        # Format a server config for a specific client type
        formatServerForClient = server:
          if clientConfig.clientType == "claude_desktop"
          then {
            name = "${server.name} API";
            type = server.type;
            apiKey = server.credentials.apiKey;
            baseUrl = server.baseUrl or null;
            # Only include path for filesystem type servers
            # This points to local model files for the Claude client to use
            path =
              if server.type == "filesystem"
              then server.path or (throw "Path must be specified for filesystem server type")
              else null;
          }
          else {
            # Generic format
            name = server.name;
            type = server.type;
            apiKey = server.credentials.apiKey;
            baseUrl = server.baseUrl or null;
            path =
              if server.type == "filesystem"
              then server.path or (throw "Path must be specified for filesystem server type")
              else null;
          };

        # Format the list of servers for this client
        formattedServers = map formatServerForClient relevantServers;

        # Generate the final client configuration structure
        clientConfigStructure =
          if clientConfig.clientType == "claude_desktop"
          then {
            mcpServers = formattedServers;
          }
          else {
            # Generic format (fallback only)
            mcpEnabled = true;
            servers = formattedServers;
          };
      in
        builtins.toJSON clientConfigStructure;

      # Function to generate client file content
      mkClientContent = clientName: clientConfig:
        pkgs.writeText "${clientName}-config.json" (mkClientConfig clientName clientConfig);

      # Function to expand path with home directory
      expandHome = path: let
        homeDir =
          if isHomeManager
          then config.home.homeDirectory
          else if pkgs.stdenv.isDarwin
          then "/Users/${builtins.getEnv "USER"}"
          else "/home/${builtins.getEnv "USER"}";
        # Replace ~ with actual home directory
        expanded = builtins.replaceStrings ["~"] [homeDir] path;
      in
        expanded;

      # Get relative path for home-manager
      getRelativePath = path: let
        homeDir =
          if isHomeManager
          then config.home.homeDirectory
          else "";
        # Strip home directory prefix if present
        relative = builtins.replaceStrings ["${homeDir}/"] [""] (expandHome path);
      in
        relative;
    in {
      options.services.mcp-clients = {
        enable = lib.mkEnableOption "MCP client configurations";

        stateDir = lib.mkOption {
          type = lib.types.str;
          default =
            if isHomeManager
            then "~/.local/state/mcp-setup"
            else "/var/lib/mcp-setup";
          description = "Directory to store MCP configuration state";
        };

        servers = lib.mkOption {
          type = lib.types.attrsOf (lib.types.submodule serverModule);
          default = {};
          description = "MCP servers configuration";
        };

        clients = lib.mkOption {
          type = lib.types.attrsOf (lib.types.submodule clientModule);
          default = {};
          description = "MCP clients to configure";
        };
      };

      # Return expanded path and config content for use in specific modules
      config._module.extraArgs = {
        mcp-clients = {
          inherit expandHome getRelativePath mkClientContent;
          enabledClients = lib.filterAttrs (_: c: c.enable) cfg.clients;
        };
      };
    };

    # NixOS module
    nixosModule = {
      config,
      lib,
      pkgs,
      mcp-clients,
      ...
    }: let
      cfg = config.services.mcp-clients;
    in {
      config = lib.mkIf cfg.enable {
        # Ensure state directory exists
        system.activationScripts.createMcpStateDir = ''
          mkdir -p ${cfg.stateDir}
          chmod 755 ${cfg.stateDir}
        '';

        # Generate configuration files for each enabled client
        system.activationScripts.setupMcpConfigs = let
          # Generate activation script for each client
          mkClientScript = name: clientConfig: let
            configFile = mcp-clients.mkClientContent name clientConfig;
            configPath = mcp-clients.expandHome clientConfig.configPath;
            configDir = builtins.dirOf configPath;
          in ''
            # Create config directory if it doesn't exist
            mkdir -p "${configDir}"

            # Write the config file
            cp ${configFile} "${configPath}"
            echo "Generated MCP config for ${name} at ${configPath}"
          '';

          # Combine all client scripts
          clientScripts = lib.mapAttrsToList mkClientScript mcp-clients.enabledClients;
        in {
          text = lib.concatStringsSep "\n" clientScripts;
        };
      };
    };

    # Darwin module
    darwinModule = {
      config,
      lib,
      pkgs,
      mcp-clients,
      ...
    }: let
      cfg = config.services.mcp-clients;
    in {
      config = lib.mkIf cfg.enable {
        # Ensure state directory exists
        system.activationScripts.createMcpStateDir = {
          text = ''
            mkdir -p ${cfg.stateDir}
            chmod 755 ${cfg.stateDir}
          '';
          deps = [];
        };

        # Generate configuration files for each enabled client
        system.activationScripts.setupMcpConfigs = let
          # Generate activation script for each client
          mkClientScript = name: clientConfig: let
            configFile = mcp-clients.mkClientContent name clientConfig;
            configPath = mcp-clients.expandHome clientConfig.configPath;
            configDir = builtins.dirOf configPath;
          in ''
            # Create config directory if it doesn't exist
            mkdir -p "${configDir}"

            # Write the config file
            cp ${configFile} "${configPath}"
            echo "Generated MCP config for ${name} at ${configPath}"
          '';

          # Combine all client scripts
          clientScripts = lib.mapAttrsToList mkClientScript mcp-clients.enabledClients;
        in {
          text = lib.concatStringsSep "\n" clientScripts;
          deps = ["createMcpStateDir"];
        };
      };
    };

    # Home-manager module
    homeManagerModule = {
      config,
      lib,
      pkgs,
      mcp-clients,
      ...
    }: let
      cfg = config.services.mcp-clients;
    in {
      config = lib.mkIf cfg.enable {
        # Generate home.file entries for each enabled client
        home.file = let
          # Generate file entry for each client
          mkClientFile = name: clientConfig: let
            configContent = mcp-clients.mkClientContent name clientConfig;
            relPath = mcp-clients.getRelativePath clientConfig.configPath;
          in {
            "${relPath}".source = configContent;
          };

          # Combine all client file entries
          clientFiles = lib.mapAttrsToList mkClientFile mcp-clients.enabledClients;
        in
          lib.foldl' lib.recursiveUpdate {} clientFiles;

        # Ensure state directory exists
        home.activation.createMcpStateDir = let
          stateDir = mcp-clients.expandHome cfg.stateDir;
        in
          lib.hm.dag.entryAfter ["writeBoundary"] ''
            mkdir -p "${stateDir}"
          '';
      };
    };

    # CLI tool generation
    mkCliTool = pkgs: let
      configTemplate = pkgs.writeText "mcp-config-template.nix" ''
        # This file was generated by mcp-setup
        {
          services.mcp-clients = {
            enable = true;

            servers = {
              # Example filesystem server configuration
              /*
              filesystem = {
                enable = true;
                name = "Local FileSystem";
                type = "filesystem";
                # Path to directory containing models or to a specific model file
                path = "/path/to/models";
                # API key isn't used for filesystem but is required by the schema
                credentials.apiKey = "not-needed";
              };
              */
            };

            clients = {
              # Example Claude Desktop configuration
              /*
              claude_desktop = {
                enable = true;
                clientType = "claude_desktop";
                # configPath will default to the correct location for your OS
              };
              */
            };
          };
        }
      '';
    in
      pkgs.writeScriptBin "mcp-setup" ''
        #!${pkgs.runtimeShell}

        set -e

        CONFIG_DIR="$HOME/.config/mcp-setup"
        CONFIG_FILE="$CONFIG_DIR/config.nix"

        mkdir -p "$CONFIG_DIR"

        echo "MCP Client Configuration Setup Tool"
        echo "----------------------------------"
        echo ""
        echo "This tool helps you configure Claude Desktop to use local model files."
        echo ""
        echo "Supported configurations:"
        echo "  - Server: FileSystem (local model files)"
        echo "  - Client: Claude Desktop"
        echo ""

        # Check if config already exists
        if [ -f "$CONFIG_FILE" ]; then
          echo "Configuration file already exists at $CONFIG_FILE"
          echo "Do you want to:"
          echo "  1. Edit the existing configuration"
          echo "  2. Create a new configuration (will overwrite existing)"
          echo "  3. Exit"
          read -p "Enter your choice (1-3): " choice

          case "$choice" in
            1)
              if command -v "$EDITOR" >/dev/null 2>&1; then
                $EDITOR "$CONFIG_FILE"
              elif command -v nano >/dev/null 2>&1; then
                nano "$CONFIG_FILE"
              elif command -v vi >/dev/null 2>&1; then
                vi "$CONFIG_FILE"
              else
                echo "No editor found. Please manually edit $CONFIG_FILE"
              fi
              ;;
            2)
              cp ${configTemplate} "$CONFIG_FILE"
              echo "New configuration template created at $CONFIG_FILE"
              echo "Please edit this file to configure your MCP servers and clients."
              ;;
            *)
              echo "Exiting without changes."
              exit 0
              ;;
          esac
        else
          # Create new config
          cp ${configTemplate} "$CONFIG_FILE"
          echo "Configuration template created at $CONFIG_FILE"
          echo "Please edit this file to configure your MCP servers and clients."
        fi

        echo ""
        echo "To use with NixOS, add this to your configuration.nix:"
        echo "  imports = [ (builtins.fetchTarball \"https://github.com/aloshy-ai/nix-mcp-servers/archive/main.tar.gz\").nixosModules.default ];"
        echo "  services.mcp-clients = (import $CONFIG_FILE).services.mcp-clients;"
        echo ""
        echo "To use with home-manager, add this to your home.nix:"
        echo "  imports = [ (builtins.fetchTarball \"https://github.com/aloshy-ai/nix-mcp-servers/archive/main.tar.gz\").nixosModules.home-manager ];"
        echo "  services.mcp-clients = (import $CONFIG_FILE).services.mcp-clients;"
        echo ""
        echo "To use with nix-darwin, add this to your darwin-configuration.nix:"
        echo "  imports = [ (builtins.fetchTarball \"https://github.com/aloshy-ai/nix-mcp-servers/archive/main.tar.gz\").darwinModules.default ];"
        echo "  services.mcp-clients = (import $CONFIG_FILE).services.mcp-clients;"
      '';

    # Per-system outputs
    perSystem = system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      # CLI setup tool
      packages.mcp-setup-cli = mkCliTool pkgs;
      packages.default = mkCliTool pkgs;

      # App definition for easy running
      apps.default = {
        type = "app";
        program = "${mkCliTool pkgs}/bin/mcp-setup";
      };
    };
  in
    # Combine all outputs
    flake-utils.lib.eachDefaultSystem perSystem
    // {
      # NixOS modules
      nixosModules = {
        default = {...}: {
          imports = [
            (mkCommonModule {isHomeManager = false;})
            nixosModule
          ];
        };

        # Include Home Manager module as a NixOS module for compatibility
        home-manager = {...}: {
          imports = [
            (mkCommonModule {isHomeManager = true;})
            homeManagerModule
          ];
        };
      };

      # Darwin modules
      darwinModules = {
        default = {...}: {
          imports = [
            (mkCommonModule {isHomeManager = false;})
            darwinModule
          ];
        };

        # Include Home Manager module as a Darwin module for compatibility
        home-manager = {...}: {
          imports = [
            (mkCommonModule {isHomeManager = true;})
            homeManagerModule
          ];
        };
      };

      # Expose individual modules for advanced use cases
      lib = {
        mkCommonModule = mkCommonModule;
        nixosModule = nixosModule;
        darwinModule = darwinModule;
        homeManagerModule = homeManagerModule;
      };
    };
}
