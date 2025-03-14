{
  pkgs,
  lib,
  options,
  revision,
  version,
}: let
  # Simple documentation generation
  manualHTML =
    pkgs.runCommand "mcp-manual-html"
    {
      nativeBuildInputs = with pkgs; [coreutils];
      meta.description = "The MCP Servers Configuration Manual";
    }
    ''
            # Create a simple HTML manual
            mkdir -p $out

            cat > $out/index.html << 'INNEREOF'
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>MCP Server Configuration Manual</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/materialize/1.0.0/css/materialize.min.css">
      </head>
      <body>
        <nav class="blue darken-1">
          <div class="nav-wrapper container">
            <a href="#" class="brand-logo">MCP Manual</a>
          </div>
        </nav>

        <div class="container">
          <div class="section">
            <h3 class="header">MCP Server Configuration Manual</h3>
            <h5 class="grey-text">Version ${version}</h5>

            <div class="divider"></div>

            <p class="flow-text">This is the MCP Servers Configuration Manual.</p>

            <h4>Introduction</h4>
            <p>The MCP Flake provides declarative configuration for Model Control Protocol servers and clients.</p>

            <h4>Features</h4>
            <ul class="collection">
              <li class="collection-item">Cross-platform support (NixOS, Darwin, home-manager)</li>
              <li class="collection-item">Pure Nix expressions for maximum compatibility</li>
              <li class="collection-item">Declarative configuration with support for secret management</li>
              <li class="collection-item">Support for various MCP servers including filesystem and GitHub servers</li>
              <li class="collection-item">Automatic generation of client configurations at appropriate OS-specific paths</li>
            </ul>

            <h4>Configuration Options</h4>
            <div class="card-panel light-blue lighten-5">
              <p>A full reference will be generated in future versions. For now, please refer to the source code.</p>
            </div>
          </div>
        </div>

        <footer class="page-footer blue darken-1">
          <div class="footer-copyright">
            <div class="container">
              MCP Server Configuration - Built with <a class="white-text" href="https://nixos.org/">Nix</a>
            </div>
          </div>
        </footer>
      </body>
      </html>
      INNEREOF

            # Add metadata for CI
            mkdir -p $out/nix-support
            echo "doc manual $out" >> $out/nix-support/hydra-build-products
    '';
in
  manualHTML
