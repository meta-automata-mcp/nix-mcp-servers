{
  pkgs,
  lib,
  revision ? "main",
  version ? null,
}:
with pkgs; let
  # Get the latest tag from GitHub for version info
  getLatestTag =
    runCommand "get-latest-tag" {
      nativeBuildInputs = [curl jq];
      SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";
      # Make this an impure operation to allow network access
      # In a real production build you might want a fixed output hash
      __impure = true;
    } ''
      # Fetch latest release tag from GitHub API
      TAG=$(curl -s https://api.github.com/repos/aloshy-ai/nix-mcp-servers/tags | jq -r '.[0].name')

      # If no tag is found, use "0.1.0-dev" as fallback
      if [ "$TAG" = "null" ] || [ -z "$TAG" ]; then
        TAG="0.1.0-dev"
      fi

      # Remove v prefix if present
      TAG=''${TAG#v}

      # Output the tag
      echo -n "$TAG" > $out
    '';

  # Use provided version or try to get latest tag (fallback to "0.1.0" if that fails)
  versionToUse =
    if version != null
    then version
    else
      (
        builtins.tryEval (builtins.readFile getLatestTag)
      )
      .value
      or "0.1.0";

  # Extract options from module definitions
  extractedOptions = import ./extract-options.nix {
    inherit lib pkgs;
    system = pkgs.stdenv.hostPlatform.system;
  };

  # Generate HTML from template
  htmlContent = import ./template.html.nix {
    inherit lib;
    options = extractedOptions;
    version = versionToUse;
  };

  # Build a static manual using the generated HTML
  manualHTML =
    runCommand "mcp-manual-html" {
      nativeBuildInputs = with pkgs; [coreutils];
      meta.description = "The MCP Servers Configuration Manual";
    } ''
            # Create output structure
            mkdir -p $out

            # Create root index.html with generated content
            cat > $out/index.html << 'INNEREOF'
      ${htmlContent}
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
