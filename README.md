# Nix MCP Servers

A Nix flake for managing Model Control Protocol (MCP) server configurations across different clients, with cross-platform support for NixOS, Home Manager, and nix-darwin.

## Current Support

### Servers
- **FileSystem**: Local filesystem-based models

### Clients
- **Claude Desktop**: Anthropic's Claude desktop application

## Installation & Usage

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

For detailed documentation on supported servers and clients, see the [docs](./docs) directory.

## Troubleshooting

If you encounter any issues with your configuration, please refer to our [troubleshooting guide](./docs/troubleshooting.md).

## License

MIT License
