# nix-mcp-servers

[![](https://img.shields.io/badge/aloshy.🅰🅸-000000.svg?style=for-the-badge)](https://aloshy.ai)
[![Powered By Nix](https://img.shields.io/badge/NIX-POWERED-5277C3.svg?style=for-the-badge&logo=nixos)](https://nixos.org)
[![Platform](https://img.shields.io/badge/MACOS-ONLY-000000.svg?style=for-the-badge&logo=apple)](https://github.com/aloshy-ai/nix-mcp-servers)
[![Build Status](https://img.shields.io/badge/BUILD-PASSING-success.svg?style=for-the-badge&logo=github)](https://github.com/aloshy-ai/nix-mcp-servers/actions)
[![License](https://img.shields.io/badge/LICENSE-MIT-blue.svg?style=for-the-badge)](./LICENSE)

A Nix flake for configuring Model Context Protocol (MCP) servers across supported AI assistant clients on macOS.

## Features

- Configures MCP servers for multiple AI assistant clients
- Currently supports Claude Desktop and Cursor
- Implements GitHub MCP server integration
- Easy configuration through nix-darwin

## Installation

### Using nix-darwin

Add the following to your `flake.nix`:

```nix
{
  inputs = {
    nix-mcp-servers.url = "github:aloshy-ai/nix-mcp-servers";
  };

  outputs = { self, darwin, nix-mcp-servers, ... }: {
    darwinConfigurations."your-hostname" = darwin.lib.darwinSystem {
      modules = [
        nix-mcp-servers.darwinModules.default
        {
          mcp-servers = {
            clients = [ "claude-desktop" "cursor" ];
            github = {
              enable = true;
              access-token = "your-github-token";
            };
          };
        }
      ];
    };
  };
}
```

## Configuration Options

| Option | Description | Type | Default |
|--------|-------------|------|---------|
| `mcp-servers.clients` | List of MCP clients to configure | List of `"claude-desktop"` or `"cursor"` | `[]` |
| `mcp-servers.github.enable` | Enable GitHub MCP server | Boolean | `false` |
| `mcp-servers.github.access-token` | GitHub personal access token | String | Required if GitHub enabled |

## Supported Clients

- **Claude Desktop**: Configures `~/Library/Application Support/Claude/claude_desktop_config.json`
- **Cursor**: Configures `~/.cursor/mcp.json`

## License

This project is licensed under the MIT License. See the [LICENSE](./LICENSE) file for details.