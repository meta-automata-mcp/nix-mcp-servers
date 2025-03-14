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
          echo "This tool configures MCP clients based on your NixOS/Darwin configuration."
        '';

        # A simpler documentation approach
        packages.docs = pkgs.runCommand "mcp-servers-docs" {} ''
          mkdir -p $out

          # Copy the module files for reference
          mkdir -p $out/modules/common
          cp ${./modules/common/options.nix} $out/modules/common/
          cp ${./modules/common/client-options.nix} $out/modules/common/
          cp ${./modules/common/server-options.nix} $out/modules/common/
          cp ${./modules/common/default.nix} $out/modules/common/

          # Create a README
          cat > $out/README.md << EOF
          # MCP Servers Documentation

          This documentation provides information about the available configuration options
          for MCP servers and clients.

          ## Available Options

          The module defines the following main option paths:

          - \`services.mcp-clients.enable\`: Enable MCP client configuration
          - \`services.mcp-clients.stateDir\`: Directory to store client state
          - \`services.mcp-clients.servers\`: Server configurations
          - \`services.mcp-clients.clients\`: Client configurations

          ## Module Source Files

          The module options are defined in the following files:

          - [options.nix](modules/common/options.nix): Main option definitions
          - [client-options.nix](modules/common/client-options.nix): Client options
          - [server-options.nix](modules/common/server-options.nix): Server options

          ## Example Configuration

          \`\`\`nix
          {
            services.mcp-clients = {
              enable = true;
              stateDir = "~/.local/state/mcp-setup";

              servers.filesystem = {
                enable = true;
                name = "Local FileSystem";
                type = "filesystem";
                path = "/path/to/models";
                credentials.apiKey = "not-needed";
              };

              clients.claude_desktop = {
                enable = true;
                clientType = "claude_desktop";
                servers = [ "filesystem" ];
              };
            };
          }
          \`\`\`
          EOF

          # Create an index.html that displays the README
          cat > $out/index.html << EOF
          <!DOCTYPE html>
          <html>
          <head>
            <meta charset="utf-8">
            <title>MCP Servers Documentation</title>
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <style>
              body { font-family: sans-serif; max-width: 1200px; margin: 0 auto; padding: 20px; line-height: 1.6; }
              h1, h2, h3 { color: #333; }
              code { background: #f4f4f4; padding: 2px 4px; border-radius: 3px; }
              pre { background: #f4f4f4; padding: 10px; border-radius: 3px; overflow-x: auto; }
              a { color: #0366d6; text-decoration: none; }
              a:hover { text-decoration: underline; }
            </style>
          </head>
          <body>
            <div id="content">Loading...</div>

            <script>
              // Fetch README and convert to HTML
              fetch('README.md')
                .then(response => response.text())
                .then(text => {
                  // Very simple Markdown to HTML conversion
                  const html = text
                    .replace(/^# (.*?)$/gm, '<h1>$1</h1>')
                    .replace(/^## (.*?)$/gm, '<h2>$1</h2>')
                    .replace(/^### (.*?)$/gm, '<h3>$1</h3>')
                    .replace(/\`\`\`(.*?)\n([\s\S]*?)\`\`\`/gm, '<pre><code>$2</code></pre>')
                    .replace(/\`([^\`]+)\`/g, '<code>$1</code>')
                    .replace(/\[([^\]]+)\]\(([^\)]+)\)/g, '<a href="$2">$1</a>')
                    .replace(/^- (.*?)$/gm, '<li>$1</li>')
                    .replace(/(<li>.*?<\/li>\n)+/g, '<ul>$&</ul>');

                  document.getElementById('content').innerHTML = html;
                })
                .catch(error => {
                  document.getElementById('content').innerHTML = 'Error loading documentation: ' + error;
                });
            </script>
          </body>
          </html>
          EOF
        '';
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
