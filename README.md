# Nix MCP Servers

A Nix flake for managing Model Control Protocol (MCP) server configurations across different clients, with cross-platform support for NixOS, Home Manager, and nix-darwin.

## Current Support

### Servers
- **FileSystem**: Local filesystem-based models

### Clients
- **Claude Desktop**: Anthropic's Claude desktop application

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
          services.mcp-clients = {
            enable = true;
            servers.local_models = {
              enable = true;
              name = "Local Models";
              type = "filesystem";
              path = "/path/to/models";
              credentials.apiKey = "not-needed";
            };
            clients.claude = {
              enable = true;
              clientType = "claude_desktop";
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
  
  services.mcp-clients = {
    enable = true;
    servers.local_models = {
      enable = true;
      name = "Local Models";
      type = "filesystem";
      path = "/path/to/models";
      credentials.apiKey = "not-needed";
    };
    clients.claude = {
      enable = true;
      clientType = "claude_desktop";
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
  
  services.mcp-clients = {
    enable = true;
    servers.local_models = {
      enable = true;
      name = "Local Models";
      type = "filesystem";
      path = "/path/to/models";
      credentials.apiKey = "not-needed";
    };
    clients.claude = {
      enable = true;
      clientType = "claude_desktop";
    };
  };
}
```

## CLI Tool

The package also provides a `mcp-setup` CLI tool to help configure your MCP servers:

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
```

You should see a JSON configuration with your FileSystem server information.

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

## Project Structure

This project uses [flake-parts](https://flake.parts/) for a modular structure:

- `modules/` - NixOS, Darwin, and Home Manager modules
  - `common/` - Shared module definitions and options
  - `nixos/` - NixOS-specific implementation
  - `darwin/` - Darwin-specific implementation
  - `home-manager/` - Home Manager implementation
- `lib/` - Utility functions used by the modules
- `docs/` - Documentation
  - `examples/` - Usage examples
  - `modules/` - Module documentation

## License

MIT License
