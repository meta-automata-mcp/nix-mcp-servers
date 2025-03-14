#!/bin/bash
set -e

# Simplify the approach with a standalone documentation builder
cat > modules/documentation/default.nix << 'EOF'
{ pkgs, lib, ... }:

{
  # This is a simplified approach that doesn't require module evaluation
  system.build.manualHTML = pkgs.callPackage ./manual.nix {
    # Basic options to pass
    options = {};
    revision = "main";
    version = "0.1.0";
  };
}
EOF

# Create a simplified manual.nix
cat > modules/documentation/manual.nix << 'EOF'
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
      mkdir -p $out/share/doc/mcp
      
      cat > $out/share/doc/mcp/index.html << 'INNEREOF'
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
  
  <p>This is a placeholder for the MCP Servers Configuration Manual.</p>
  
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
      echo "doc manual $out/share/doc/mcp" >> $out/nix-support/hydra-build-products
    '';

in manualHTML
EOF

# Update flake.nix to use the simplified module
# Create a temporary file for the modified flake.nix
cat > flake.nix.tmp << 'EOF'
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
      }: let
        mcp-setup = pkgs.writeShellScriptBin "mcp-setup" ''
          echo "MCP Setup CLI"
          echo "This tool configures MCP clients based on your NixOS/Darwin configuration."
        '';
        
        # Simple manual builder
        manualHTML = pkgs.callPackage ./modules/documentation/manual.nix {
          options = {};
          revision = self.rev or "main";
          version = "0.1.0";
        };
      in {
        # CLI tool package
        packages.mcp-setup = mcp-setup;

        # Set the default package
        packages.default = mcp-setup;
        
        # Documentation output
        packages.manualHTML = manualHTML;
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
EOF

# Replace original flake.nix with our updated version
mv flake.nix.tmp flake.nix

echo "Simplified documentation approach applied. Try building with 'nix build .#manualHTML'"
