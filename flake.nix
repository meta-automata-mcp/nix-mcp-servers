{
  description = "MCP server configuration management for various clients";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-parts,
    home-manager,
    darwin,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];

      perSystem = {
        system,
        pkgs,
        ...
      }: {
        # CLI tool package
        packages.mcp-setup = pkgs.writeShellScriptBin "mcp-setup" ''
          echo "MCP Setup CLI"
          echo "=============="
          echo "This tool configures MCP clients based on your NixOS/Darwin configuration."
        '';

        # Documentation package using mdBook
        packages.docs = pkgs.stdenv.mkDerivation {
          name = "mcp-servers-docs";
          src = pkgs.writeTextDir "book.toml" ''
            [book]
            title = "MCP Servers Documentation"
            authors = ["aloshy-ai"]
            description = "Documentation for MCP server configuration management"
            language = "en"

            [output.html]
            default-theme = "light"
            preferred-dark-theme = "navy"
            git-repository-url = "https://github.com/aloshy-ai/nix-mcp-servers"
          '';

          buildInputs = [pkgs.mdbook];

          buildPhase = ''
            mkdir -p src

            # Create introduction page
            cat > src/SUMMARY.md << EOF
            # Summary

            - [Introduction](./introduction.md)
            - [Module Options](./options.md)
            - [Examples](./examples.md)
            EOF

            cat > src/introduction.md << EOF
            # MCP Servers

            MCP server configuration management for NixOS, Darwin, and Home Manager.

            This module provides a standardized way to configure MCP clients and servers
            across different platforms.

            ## Features

            - Configure MCP clients for various platforms
            - Manage server configurations
            - Consistent interface across NixOS, Darwin, and Home Manager
            EOF

            cat > src/options.md << EOF
            # Module Options

            ## Common Options

            - **services.mcp-clients.enable**: Enable MCP client configuration
            - **services.mcp-clients.stateDir**: Directory for client state
            - **services.mcp-clients.servers**: Server configurations
            - **services.mcp-clients.clients**: Client configurations

            ## Server Options

            - **services.mcp-clients.servers.<name>.enable**: Enable this server
            - **services.mcp-clients.servers.<name>.type**: Server type (e.g., "filesystem")
            - **services.mcp-clients.servers.<name>.baseUrl**: Base URL for the server
            - **services.mcp-clients.servers.<name>.path**: Path for filesystem-based servers
            - **services.mcp-clients.servers.<name>.credentials**: Credentials for authentication

            ## Client Options

            - **services.mcp-clients.clients.<name>.enable**: Enable this client
            - **services.mcp-clients.clients.<name>.clientType**: Client type (e.g., "claude_desktop")
            - **services.mcp-clients.clients.<name>.configPath**: Path to client configuration
            - **services.mcp-clients.clients.<name>.servers**: List of servers to use
            EOF

            cat > src/examples.md << EOF
            # Examples

            ## Basic Configuration

            \`\`\`nix
            {
              services.mcp-clients = {
                enable = true;
                stateDir = "/var/lib/mcp-clients";

                servers.local = {
                  enable = true;
                  type = "filesystem";
                  path = "/path/to/models";
                };

                clients.claude = {
                  enable = true;
                  clientType = "claude_desktop";
                  servers = [ "local" ];
                };
              };
            }
            \`\`\`
            EOF

            # Build the book
            mdbook build
          '';

          installPhase = ''
            mkdir -p $out
            cp -r book/* $out/
          '';
        };
      };

      flake = {
        lib = import ./lib {
          inherit (nixpkgs) lib;
        };

        nixosModules = {
          default = {...}: {
            imports = [
              ./modules/common
              ./modules/nixos
            ];
          };

          home-manager = {...}: {
            imports = [
              ./modules/common
              ./modules/home-manager
            ];
          };
        };

        darwinModules = {
          default = {...}: {
            imports = [
              ./modules/common
              ./modules/darwin
            ];
          };

          home-manager = {...}: {
            imports = [
              ./modules/common
              ./modules/home-manager
            ];
          };
        };
      };
    };
}
