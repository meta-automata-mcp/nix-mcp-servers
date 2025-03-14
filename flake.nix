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

        # Documentation generation
        packages.docs = let
          # Evaluate modules to extract options
          eval = pkgs.lib.evalModules {
            modules = [
              {imports = [./modules/common];}
            ];
            specialArgs = {inherit pkgs;};
          };

          # Generate options documentation
          optionsDoc = pkgs.nixosOptionsDoc {
            options = eval.options;
            # Use a simpler markdown format
            transformOptions = opt:
              opt
              // {
                declarations = map (d: d.outPath) (opt.declarations or []);
              };
          };
        in
          pkgs.runCommand "mcp-servers-docs" {} ''
            mkdir -p $out

            # Copy the options documentation
            cp -r ${optionsDoc.optionsCommonMark} $out/options.md

            # Copy documentation files
            cp -r ${./docs}/* $out/

            # Create a simple index HTML file that displays the options
            cat > $out/index.html << EOF
            <!DOCTYPE html>
            <html>
            <head>
              <meta charset="utf-8">
              <title>MCP Servers Documentation</title>
              <meta name="viewport" content="width=device-width, initial-scale=1">
              <style>
                body {
                  font-family: system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
                  max-width: 1200px;
                  margin: 0 auto;
                  padding: 20px;
                  line-height: 1.6;
                  color: #333;
                }
                h1, h2, h3 { color: #2462c2; }
                h1 { border-bottom: 1px solid #eee; padding-bottom: 0.3em; }
                code { background: #f6f8fa; padding: 2px 4px; border-radius: 3px; font-family: 'SFMono-Regular', Consolas, 'Liberation Mono', Menlo, monospace; }
                pre { background: #f6f8fa; padding: 16px; border-radius: 6px; overflow-x: auto; }
                a { color: #0366d6; text-decoration: none; }
                a:hover { text-decoration: underline; }
                .option-path { font-weight: bold; background-color: #f0f7ff; border-left: 3px solid #2462c2; padding: 8px 12px; margin: 20px 0 10px 0; }
                .option-type { color: #6a737d; font-style: italic; }
                .option-default { background-color: #f6f8fa; padding: 8px; border-radius: 3px; margin-top: 5px; }
                .option-description { margin-top: 10px; }
                details { margin: 10px 0; }
                summary { cursor: pointer; }
                nav { background: #f8f9fa; padding: 15px; border-radius: 5px; margin-bottom: 20px; }
                nav ul { list-style-type: none; padding: 0; margin: 0; }
                nav li { margin-bottom: 8px; }
              </style>
            </head>
            <body>
              <h1>MCP Servers Documentation</h1>

              <nav>
                <h2>Contents</h2>
                <ul>
                  <li><a href="#intro">Introduction</a></li>
                  <li><a href="#options">Configuration Options</a></li>
                  <li><a href="default.xml">XML Documentation</a> (if available)</li>
                </ul>
              </nav>

              <div id="intro">
                <h2>Introduction</h2>
                <p>This documentation provides information about all configuration options for the MCP servers and clients.</p>
                <p>These modules allow you to configure various model serving setups across different platforms.</p>
              </div>

              <h2 id="options">Configuration Options</h2>
              <div id="options-content">
                <p>Loading options documentation...</p>
              </div>

              <script>
                // Fetch and format the options markdown
                fetch('options.md')
                  .then(response => response.text())
                  .then(text => {
                    // Format the options documentation
                    let html = text
                      // Format headers
                      .replace(/^# (.*?)$/gm, '<h2>$1</h2>')
                      .replace(/^## (.*?)$/gm, '<h3>$1</h3>')
                      .replace(/^### (.*?)$/gm, '<h4>$1</h4>')

                      // Format option paths more prominently
                      .replace(/^#### `(.*?)`$/gm, '<div class="option-path">$1</div>')

                      // Format code blocks
                      .replace(/\`\`\`(.*?)\n([\s\S]*?)\`\`\`/gm, '<pre><code>$2</code></pre>')

                      // Format inline code
                      .replace(/\`([^\`]+)\`/g, '<code>$1</code>')

                      // Format links
                      .replace(/\[([^\]]+)\]\(([^\)]+)\)/g, '<a href="$2">$1</a>')

                      // Format lists
                      .replace(/^- (.*?)$/gm, '<li>$1</li>')
                      .replace(/(<li>.*?<\/li>\n)+/g, '<ul>$&</ul>')

                      // Format option types
                      .replace(/\*Type:\s*([^*]+)\*/g, '<div class="option-type">Type: $1</div>')

                      // Format default values
                      .replace(/\*Default:\s*([^*]+)\*/g, '<div class="option-default">Default: $1</div>')

                      // Format option descriptions for better readability
                      .replace(/\n+([^<\n].*?)\n+/g, '<div class="option-description">$1</div>');

                    document.getElementById('options-content').innerHTML = html;
                  })
                  .catch(error => {
                    document.getElementById('options-content').innerHTML = 'Error loading documentation: ' + error;
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
