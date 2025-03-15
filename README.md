# Nix MCP Servers

[![](https://img.shields.io/badge/aloshy.🅰🅸-000000.svg?style=for-the-badge)](https://aloshy.ai)
[![Powered By Nix](https://img.shields.io/badge/NIX-POWERED-5277C3.svg?style=for-the-badge&logo=nixos)](https://nixos.org)
[![Build Status](https://img.shields.io/github/actions/workflow/status/aloshy-ai/nix-mcp-servers/ci.yml?style=for-the-badge&logo=github)](https://github.com/aloshy-ai/nix-mcp-servers/actions)
[![License](https://img.shields.io/badge/LICENSE-MIT-blue.svg?style=for-the-badge)](./LICENSE)

A Nix flake for declaratively configuring MCP (Model Context Protocol) servers for clients like Claude and Cursor.

## Features

- Declarative configuration of MCP servers
- Support for multiple clients (Claude, Cursor)
- Support for multiple server types (filesystem, github)
- Cross-platform support (NixOS, Darwin)
- Uses Home Manager for integration with your existing Nix configuration

## How it Works

This flake provides Home Manager modules that generate MCP server configuration files for different clients. When you enable a server for a client, the necessary configuration is generated and placed in the appropriate location for that client.

## Supported Servers

- **Filesystem**: Provides filesystem access to AI models
- **GitHub**: Provides GitHub access to AI models

## Supported Clients

- **Claude**: Anthropic's Claude AI assistant
- **Cursor**: The Cursor code editor

## Usage

### Basic Usage

Add this flake to your home-manager configuration:

```nix
{
  inputs = {
    # ... your other inputs
    nix-mcp-servers.url = "github:yourusername/nix-mcp-servers";
  };

  outputs = { nixpkgs, home-manager, nix-mcp-servers, ... }: {
    homeConfigurations."yourusername" = home-manager.lib.homeManagerConfiguration {
      # ... your other configuration
      modules = [
        nix-mcp-servers.homeManagerModules.default
        
        # Your configuration
        {
          nix-mcp = {
            # Enable configuration generation
            clients.generateConfigs = true;
            
            # Configure Cursor client
            clients.cursor = {
              enable = true;
              
              # Enable filesystem server for Cursor
              filesystem = {
                enable = true;
                paths = [
                  "/Users/yourusername/projects"
                  "/Users/yourusername/Documents"
                ];
              };
              
              # Enable GitHub server for Cursor
              github = {
                enable = true;
                token = "your-github-token";
              };
            };
            
            # Configure Claude client
            clients.claude = {
              enable = true;
              
              # Only enable filesystem for Claude
              filesystem = {
                enable = true;
                paths = [
                  "/Users/yourusername/projects"
                ];
              };
              
              # Don't enable GitHub for Claude
              github.enable = false;
            };
          };
        }
      ];
    };
  };
}
```

### Custom Configuration Paths

You can customize the configuration paths for each client:

```nix
{
  nix-mcp = {
    # Override base config path
    configPath = "/custom/path/to/mcp";
    
    clients.cursor = {
      enable = true;
      # Override Cursor config path
      configPath = "/custom/path/to/cursor/mcp/config.json";
      
      # ...rest of the configuration
    };
  };
}
```

## Development

To contribute to this project:

1. Clone the repository
2. Make your changes
3. Test with `nix flake check`
4. Submit a PR

## License

[MIT License](LICENSE)

## Project Overview

This Nix flake provides a unified configuration system for Model Control Protocol (MCP) servers across different platforms and package managers. The project:

- Manages MCP server configurations for AI applications
- Handles client-specific configuration formats and paths
- Works across NixOS, nix-darwin, and Home Manager
- Provides cross-platform compatibility between Linux and macOS
- Supports multiple server types with server-specific configuration options

## Installation & Usage

For detailed usage examples, see our documentation:
- [NixOS Example](./docs/examples/nixos.md)
- [Home Manager Example](./docs/examples/home-manager.md)
- [Darwin Example](./docs/examples/darwin.md)

Quick start:

### NixOS

Add to your configuration.nix:

```nix
{
  inputs.mcp-servers.url = "github:aloshy-ai/nix-mcp-servers";
  
  outputs = { self, nixpkgs, mcp-servers, ... }: {
    nixosConfigurations.hostname = nixpkgs.lib.nixosSystem {
      # ...
      modules = [
        mcp-servers.nixosModules.default
        {
          services.mcp-servers = {
            enable = true; # Enable the entire module
            
            servers = {
              filesystem = {
                # command = "npx"; # Uses default
                filesystem = {
                  # args = [ "-y" "@modelcontextprotocol/server-filesystem" ]; # Uses default
                  extraArgs = [ "/Users/username/Desktop" "/path/to/other/allowed/dir" ]; # REQUIRED
                };
              };
              
              github = {
                env = {
                  GITHUB_PERSONAL_ACCESS_TOKEN = "xxxxxxxxxxxxxxx"; # REQUIRED through assertion
                };
              };
            };
            
            clients = {
              claude = {
                enable = true; # Using standard Nix 'enable' flag
                # clientType defaults to "claudeDesktop" based on name
                servers = [ "filesystem" "github" ];
              };
              
              cursor = {
                enable = true; # Enable Cursor configuration 
                servers = [ "filesystem" ]; # Only use filesystem server for Cursor
              };
            };
          };
        }
      ];
    };
  };
}
```

### Home Manager

Add to your home.nix:

```nix
{
  imports = [
    (builtins.fetchTarball "https://github.com/aloshy-ai/nix-mcp-servers/archive/main.tar.gz").nixosModules.home-manager
  ];
  
  services.mcp-servers = {
    enable = true; # Enable the entire module
    
    servers = {
      filesystem = {
        # command = "npx"; # Uses default
        filesystem = {
          # args = [ "-y" "@modelcontextprotocol/server-filesystem" ]; # Uses default
          extraArgs = [ "/Users/username/Desktop" "/path/to/other/allowed/dir" ]; # REQUIRED
        };
      };
      
      github = {
        env = {
          GITHUB_PERSONAL_ACCESS_TOKEN = "xxxxxxxxxxxxxxx"; # REQUIRED through assertion
        };
      };
    };
    
    clients = {
      claude = {
        enable = true; # Using standard Nix 'enable' flag
        # clientType defaults to "claudeDesktop" based on name
        servers = [ "filesystem" "github" ];
      };
      
      cursor = {
        enable = true; # Enable Cursor configuration
        servers = [ "filesystem" ]; # Only use filesystem server for Cursor
      };
    };
  };
}
```

### nix-darwin

Add to your darwin-configuration.nix:

```nix
{
  imports = [
    (builtins.fetchTarball "https://github.com/aloshy-ai/nix-mcp-servers/archive/main.tar.gz").darwinModules.default
  ];
  
  services.mcp-servers = {
    enable = true; # Enable the entire module
    
    servers = {
      filesystem = {
        # command = "npx"; # Uses default
        filesystem = {
          # args = [ "-y" "@modelcontextprotocol/server-filesystem" ]; # Uses default
          extraArgs = [ "/Users/username/Desktop" "/path/to/other/allowed/dir" ]; # REQUIRED
        };
      };
      
      github = {
        env = {
          GITHUB_PERSONAL_ACCESS_TOKEN = "xxxxxxxxxxxxxxx"; # REQUIRED through assertion
        };
      };
    };
    
    clients = {
      claude = {
        enable = true; # Using standard Nix 'enable' flag
        # clientType defaults to "claudeDesktop" based on name
        servers = [ "filesystem" "github" ];
      };
      
      cursor = {
        enable = true; # Enable Cursor configuration
        servers = [ "filesystem" ]; # Only use filesystem server for Cursor
      };
    };
  };
}
```

## CLI Tool

The package also provides a `mcp-servers` CLI tool to help configure your MCP servers:

```bash
nix run github:aloshy-ai/nix-mcp-servers
```

## Testing Your Setup

After configuring the MCP server, you can verify the configuration was applied correctly:

### For NixOS and nix-darwin

```bash
# For NixOS
sudo nixos-rebuild test

# For nix-darwin
darwin-rebuild test
```

### For Home Manager

```bash
home-manager switch
```

Then check if the configuration file exists:

```bash
# For Claude Desktop on macOS
cat ~/Library/Application\ Support/Claude/mcp-config.json

# For Claude Desktop on Linux
cat ~/.config/claude-desktop/mcp-config.json

# For Cursor on macOS
cat ~/Library/Application\ Support/Cursor/mcp-config.json

# For Cursor on Linux
cat ~/.config/Cursor/mcp-config.json
```

You should see a JSON configuration with your configured server information.

## Module Structure

This project uses a modular structure for handling configuration across different platforms:

- **Common Options**: Defines the core module options for servers and clients
- **Platform Adapters**: Implements platform-specific configuration for NixOS, Darwin, and Home Manager
- **Library Functions**: Provides helper functions for path handling, platform detection, and configuration generation

## Project Structure

This project uses [flake-parts](https://flake.parts/) for a modular structure:

- `modules/` - NixOS, Darwin, and Home Manager modules
  - `common/` - Shared module definitions and options
  - `nixos/` - NixOS-specific implementation
  - `darwin/` - Darwin-specific implementation
  - `home-manager/` - Home Manager implementation
- `lib/` - Utility functions used by the modules
  - `clients.nix` - Client-specific configuration handling
  - `servers.nix` - Server configuration formatting
  - `platforms.nix` - Platform detection and path utilities
  - `paths.nix` - Path manipulation functions
- `docs/` - Documentation
  - `examples/` - Usage examples
  - `modules/` - Module documentation

## Documentation

- [Module Options](./docs/modules/options.md) - Detailed documentation of all available options
- [Usage Examples](./docs/examples/) - Examples for different platforms
- [Troubleshooting](./docs/troubleshooting.md) - Solutions for common issues

You can also generate and view the options documentation directly with:

```bash
nix run github:aloshy-ai/nix-mcp-servers#view-docs
```

## GitHub Pages Documentation

This repository is configured to automatically build and deploy documentation to GitHub Pages. The documentation is generated from the `docs` package in the flake and deployed whenever changes are pushed to the main branch.

The deployment is handled by the [peaceiris/actions-gh-pages](https://github.com/peaceiris/actions-gh-pages) action, which creates a `gh-pages` branch with the documentation. This approach doesn't require any manual configuration of the GitHub Pages environment.

The URL to the generated documentation will be displayed in the GitHub repository details once deployed.
