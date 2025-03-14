{
  pkgs,
  lib,
  options,
  revision,
  version,
}: let
  # Simple documentation generation
  manualHTML =
    pkgs.runCommand "mcp-manual-html" {
      nativeBuildInputs = with pkgs; [coreutils];
      meta.description = "The MCP Servers Configuration Manual";
    } ''
          # Create a simple HTML manual
          mkdir -p $out

          cat > $out/index.html << 'INNEREOF'
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta name="color-scheme" content="light dark">
        <title>MCP Server Configuration Manual</title>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.classless.min.css">
      </head>
      <body>
        <header>
          <hgroup>
            <h1>MCP Server Configuration Manual</h1>
            <h2>Version ${version}</h2>
          </hgroup>
        </header>

        <main>
          <p>This is the MCP Servers Configuration Manual.</p>

          <section>
            <h2>Introduction</h2>
            <p>The MCP Flake provides declarative configuration for Model Control Protocol servers and clients.</p>
          </section>

          <section>
            <h2>Features</h2>
            <ul>
              <li>Cross-platform support (NixOS, Darwin, home-manager)</li>
              <li>Pure Nix expressions for maximum compatibility</li>
              <li>Declarative configuration with support for secret management</li>
              <li>Support for various MCP servers including filesystem and GitHub servers</li>
              <li>Automatic generation of client configurations at appropriate OS-specific paths</li>
            </ul>
          </section>

          <section>
            <h2>Configuration Options</h2>
            <article>
              <p>A full reference will be generated in future versions. For now, please refer to the source code.</p>
            </article>
          </section>
        </main>

        <footer>
          <small>MCP Server Configuration - Built with <a href="https://nixos.org/">Nix</a></small>
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
