# modules/documentation/template.html.nix
{
  lib,
  options,
  version,
}: let
  # Helper function to render option details
  renderOption = path: opt: ''
    <div>
      <h4><code>${path}</code></h4>
      <p>${opt.description}</p>
      <details>
        <summary>Details</summary>
        <ul>
          <li><strong>Type:</strong> ${opt.type}</li>
          ${
      if opt.default != null
      then "<li><strong>Default:</strong> ${opt.default}</li>"
      else ""
    }
          ${
      if opt.example != null
      then "<li><strong>Example:</strong> ${opt.example}</li>"
      else ""
    }
        </ul>
      </details>
    </div>
  '';

  # Render base options
  baseOptions = lib.concatStringsSep "\n" (
    lib.mapAttrsToList
    (name: opt: renderOption "services.mcpServers.${name}" opt)
    (options.base or {})
  );

  # Render server options
  serverOptions = lib.concatStringsSep "\n" (
    lib.mapAttrsToList
    (name: opt: renderOption "services.mcpServers.servers.<name>.${name}" opt)
    (options.servers or {})
  );

  # Render client options
  clientOptions = lib.concatStringsSep "\n" (
    lib.mapAttrsToList
    (name: opt: renderOption "services.mcpServers.clients.<name>.${name}" opt)
    (options.clients or {})
  );

  # Render filesystem server options
  filesystemOptions = lib.concatStringsSep "\n" (
    lib.mapAttrsToList
    (name: opt: renderOption "services.mcpServers.servers.<name>.filesystem.${name}" opt)
    (options.filesystem or {})
  );
in ''
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
          <h3>Base Options</h3>
          ${baseOptions}
        </article>

        <article>
          <h3>Server Options</h3>
          ${serverOptions}
        </article>

        <article>
          <h3>Client Options</h3>
          ${clientOptions}
        </article>

        <article>
          <h3>Filesystem Server Options</h3>
          ${filesystemOptions}
        </article>
      </section>

      <section>
        <h2>Example Configuration</h2>
        <pre><code>{
    services.mcpServers = {
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
''
