{
  pkgs,
  lib,
  revision ? "main",
  version ? "0.1.0",
}:
with pkgs; let
  # Build a static manual without trying to evaluate modules
  manualHTML =
    runCommand "mcp-manual-html" {
      nativeBuildInputs = with pkgs; [coreutils];
      meta.description = "The MCP Servers Configuration Manual";
    } ''
          # Create output structure
          mkdir -p $out

          # Create root index.html with embedded option documentation
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
          <p>Welcome to the MCP Servers Configuration Manual.</p>
        </header>

        <main>
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
              <h3>Server Options</h3>

              <div>
                <h4><code>services.mcp-clients.servers.&lt;name&gt;.enable</code></h4>
                <p>Enable or disable this MCP server configuration.</p>
                <details>
                  <summary>Details</summary>
                  <ul>
                    <li><strong>Type:</strong> boolean</li>
                    <li><strong>Default:</strong> false</li>
                    <li><strong>Example:</strong> true</li>
                  </ul>
                </details>
              </div>

              <div>
                <h4><code>services.mcp-clients.servers.&lt;name&gt;.command</code></h4>
                <p>Command to run the MCP server.</p>
                <details>
                  <summary>Details</summary>
                  <ul>
                    <li><strong>Type:</strong> string</li>
                    <li><strong>Default:</strong> "npx"</li>
                    <li><strong>Example:</strong> "/path/to/custom/command"</li>
                  </ul>
                </details>
              </div>

              <div>
                <h4><code>services.mcp-clients.servers.&lt;name&gt;.env</code></h4>
                <p>Environment variables to set when running the server.</p>
                <details>
                  <summary>Details</summary>
                  <ul>
                    <li><strong>Type:</strong> attribute set of strings</li>
                    <li><strong>Default:</strong> {}</li>
                    <li><strong>Example:</strong> { GITHUB_PERSONAL_ACCESS_TOKEN = "ghp_abcdef123456"; }</li>
                  </ul>
                </details>
              </div>

              <div>
                <h4><code>services.mcp-clients.servers.&lt;name&gt;.type</code></h4>
                <p>Type of MCP server.</p>
                <details>
                  <summary>Details</summary>
                  <ul>
                    <li><strong>Type:</strong> string</li>
                    <li><strong>Example:</strong> "filesystem" or "github"</li>
                  </ul>
                </details>
              </div>
            </article>

            <article>
              <h3>Client Options</h3>

              <div>
                <h4><code>services.mcp-clients.clients.&lt;name&gt;.enable</code></h4>
                <p>Whether to enable this MCP client configuration.</p>
                <details>
                  <summary>Details</summary>
                  <ul>
                    <li><strong>Type:</strong> boolean</li>
                    <li><strong>Default:</strong> false</li>
                    <li><strong>Example:</strong> true</li>
                  </ul>
                </details>
              </div>

              <div>
                <h4><code>services.mcp-clients.clients.&lt;name&gt;.clientType</code></h4>
                <p>Type of MCP client to configure.</p>
                <details>
                  <summary>Details</summary>
                  <ul>
                    <li><strong>Type:</strong> string, one of "claudeDesktop", "cursor"</li>
                    <li><strong>Default:</strong> Depends on the client name</li>
                    <li><strong>Example:</strong> "claudeDesktop"</li>
                  </ul>
                </details>
              </div>

              <div>
                <h4><code>services.mcp-clients.clients.&lt;name&gt;.configPath</code></h4>
                <p>Path to the client configuration file. If not specified, a default path will be used.</p>
                <details>
                  <summary>Details</summary>
                  <ul>
                    <li><strong>Type:</strong> string</li>
                    <li><strong>Default:</strong> ""</li>
                    <li><strong>Example:</strong> "~/Library/Application Support/Claude/claude_desktop_config.json"</li>
                  </ul>
                </details>
              </div>

              <div>
                <h4><code>services.mcp-clients.clients.&lt;name&gt;.servers</code></h4>
                <p>List of MCP server names to enable for this client.</p>
                <details>
                  <summary>Details</summary>
                  <ul>
                    <li><strong>Type:</strong> list of strings</li>
                    <li><strong>Default:</strong> []</li>
                    <li><strong>Example:</strong> ["filesystem", "github"]</li>
                  </ul>
                </details>
              </div>
            </article>

            <article>
              <h3>Filesystem Server Options</h3>

              <div>
                <h4><code>services.mcp-clients.servers.&lt;name&gt;.filesystem.args</code></h4>
                <p>Default arguments for the filesystem MCP server.</p>
                <details>
                  <summary>Details</summary>
                  <ul>
                    <li><strong>Type:</strong> list of strings</li>
                    <li><strong>Default:</strong> ["-y", "@modelcontextprotocol/server-filesystem"]</li>
                  </ul>
                </details>
              </div>

              <div>
                <h4><code>services.mcp-clients.servers.&lt;name&gt;.filesystem.extraArgs</code></h4>
                <p>Directories to provide access to.</p>
                <details>
                  <summary>Details</summary>
                  <ul>
                    <li><strong>Type:</strong> list of strings</li>
                    <li><strong>Example:</strong> ["/home/user/Documents", "/home/user/Projects"]</li>
                  </ul>
                </details>
              </div>
            </article>
          </section>

          <section>
            <h2>Example Configuration</h2>
            <pre><code>{
        services.mcp-clients = {
          enable = true;

          servers.filesystem = {
            enable = true;
            type = "filesystem";
            command = "npx";
            filesystem.extraArgs = [
              "/home/user/projects"
              "/home/user/documents"
            ];
          };

          servers.github = {
            enable = true;
            type = "github";
            command = "npx";
            env.GITHUB_PERSONAL_ACCESS_TOKEN = "ghp_yourtokenhere";
          };

          clients.claude = {
            enable = true;
            clientType = "claudeDesktop";
            servers = [ "filesystem" "github" ];
          };

          clients.cursor = {
            enable = true;
            clientType = "cursor";
            servers = [ "filesystem" ];
          };
        };
      }</code></pre>
          </section>

          <section>
            <h2>Source Code</h2>
            <p>For more details, check out the <a href="https://github.com/aloshy-ai/nix-mcp-servers">source code on GitHub</a>.</p>
          </section>
        </main>

        <footer>
          <small>MCP Server Configuration - Built with <a href="https://nixos.org/">Nix</a></small>
        </footer>
      </body>
      </html>
      INNEREOF

          # Add a 404 page
          cat > $out/404.html << 'INNEREOF'
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta name="color-scheme" content="light dark">
        <title>Page Not Found</title>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.classless.min.css">
      </head>
      <body>
        <header>
          <h1>Page Not Found</h1>
        </header>
        <main>
          <p>The page you're looking for doesn't exist.</p>
          <p><a href="/">Go to the homepage</a></p>
        </main>
      </body>
      </html>
      INNEREOF
    '';
in
  manualHTML
