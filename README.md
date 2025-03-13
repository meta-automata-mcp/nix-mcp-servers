# Nix MCP Servers Configuration

A Nix flake for managing MCP (Model Control Protocol) server configurations across multiple clients. This flake provides system-agnostic configuration management for AI clients like Claude Desktop, Cursor IDE, and others.

## Features

- Cross-platform support for NixOS, Darwin (macOS), and home-manager
- Pure Nix expressions for configuration management
- Declarative configuration with support for secret management
- Support for multiple MCP clients and servers

## Usage

Add this flake to your NixOS, nix-darwin, or home-manager configuration.

### NixOS Example

```nix
{
  inputs.mcp-servers.url = "github:aloshy-ai/nix-mcp-servers";
  
  outputs = { self, nixpkgs, mcp-servers, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      # ...
      modules = [
        mcp-servers.nixosModules.default
        {
          services.mcp-clients = {
            enable = true;
            # Configuration here...
          };
        }
      ];
    };
  };
}
```

### Home Manager Example

```nix
{
  imports = [
    inputs.mcp-servers.homeManagerModules.default
  ];
  
  services.mcp-clients = {
    enable = true;
    # Configuration here...
  };
}
```

## License

MIT
