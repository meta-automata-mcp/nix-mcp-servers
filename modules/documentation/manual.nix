{ pkgs, lib, options, revision, version }:

let
  # Simple documentation generation
  manualHTML = pkgs.runCommand "mcp-manual-html"
    { 
      nativeBuildInputs = with pkgs; [ coreutils ];
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
  <title>MCP Server Configuration Manual</title>
  <style>
    body { font-family: sans-serif; line-height: 1.5; max-width: 800px; margin: 0 auto; padding: 2em; }
    h1, h2 { color: #333; }
    code { background: #f5f5f5; padding: 0.2em; }
    pre { background: #f5f5f5; padding: 1em; overflow-x: auto; }
  </style>
</head>
<body>
  <h1>MCP Server Configuration Manual</h1>
  <h2>Version ${version}</h2>
  
  <p>This is the MCP Servers Configuration Manual.</p>
  
  <h2>Introduction</h2>
  <p>The MCP Flake provides declarative configuration for Model Control Protocol servers and clients.</p>
  
  <h2>Features</h2>
  <ul>
    <li>Cross-platform support (NixOS, Darwin, home-manager)</li>
    <li>Pure Nix expressions for maximum compatibility</li>
    <li>Declarative configuration with support for secret management</li>
    <li>Support for various MCP servers including filesystem and GitHub servers</li>
    <li>Automatic generation of client configurations at appropriate OS-specific paths</li>
  </ul>
  
  <h2>Configuration Options</h2>
  <p>A full reference will be generated in future versions. For now, please refer to the source code.</p>
</body>
</html>
INNEREOF
      
      # Add metadata for CI
      mkdir -p $out/nix-support
      echo "doc manual $out" >> $out/nix-support/hydra-build-products
    '';

in manualHTML
