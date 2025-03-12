# nix-mcp-servers

[![](https://img.shields.io/badge/aloshy.🅰🅸-000000.svg?style=for-the-badge)](https://aloshy.ai)
[![Powered By Nix](https://img.shields.io/badge/NIX-POWERED-5277C3.svg?style=for-the-badge&logo=nixos)](https://nixos.org)
[![Platform](https://img.shields.io/badge/MACOS-ONLY-000000.svg?style=for-the-badge&logo=apple)](https://github.com/aloshy-ai/nix-mcp-servers)
[![Build Status](https://img.shields.io/github/actions/workflow/status/aloshy-ai/nix-mcp-servers/ci.yml?style=for-the-badge&logo=github)](https://github.com/aloshy-ai/nix-mcp-servers/actions)
[![License](https://img.shields.io/badge/LICENSE-MIT-blue.svg?style=for-the-badge)](./LICENSE)

A Nix flake providing Darwin modules for configuring Model Context Protocol (MCP) servers across supported AI assistant clients on macOS.

## Features

- Automated configuration of MCP servers for AI assistant clients
- Platform-aware client support (currently macOS only)
- Supports multiple MCP server types:
  - GitHub (with token authentication)
  - GitLab (with optional self-hosted instance support)
  - Filesystem (with path validation and normalization)
- Supported clients:
  - Claude Desktop
  - Cursor
- Runtime path validation and permissions checking
- Automatic config file management

## Installation

Add to your `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mcp-servers.url = "github:aloshy-ai/nix-mcp-servers";
  };

  outputs = { self, nixpkgs, darwin, mcp-servers }: {
    darwinConfigurations."your-hostname" = darwin.lib.darwinSystem {
      system = "aarch64-darwin";  # or "x86_64-darwin" for Intel Macs
      modules = [
        mcp-servers.darwinModules.default
        {
          mcp-servers.servers = {
            # GitHub Configuration
            github = {
              enable = true;
              access-token = "ghp_your_github_token";
            };

            # GitLab Configuration (Optional)
            gitlab = {
              enable = true;
              access-token = "glpat_your_gitlab_token";
              api-url = "https://gitlab.company.com/api/v4";  # Optional, for self-hosted
            };

            # Filesystem Configuration
            filesystem = {
              enable = true;
              allowed-paths = [
                "~/Documents/Projects"
                "/Users/shared/team-projects"
              ];
            };
          };
        }
      ];
    };
  };
}
```

## Configuration Options

### Server Configuration

Each server type has its own configuration options:

#### GitHub Server
| Option | Type | Description | Default | Required |
|--------|------|-------------|---------|----------|
| `enable` | boolean | Enable GitHub MCP server | `false` | No |
| `access-token` | string | GitHub personal access token | `""` | Yes, if enabled |

#### GitLab Server
| Option | Type | Description | Default | Required |
|--------|------|-------------|---------|----------|
| `enable` | boolean | Enable GitLab MCP server | `false` | No |
| `access-token` | string | GitLab personal access token | `""` | Yes, if enabled |
| `api-url` | string | GitLab API URL for self-hosted instances | `""` | No |

#### Filesystem Server
| Option | Type | Description | Default | Required |
|--------|------|-------------|---------|----------|
| `enable` | boolean | Enable Filesystem MCP server | `false` | No |
| `allowed-paths` | [string] | List of paths to allow access to | `[]` | Yes, if enabled |

### Client Support

The module automatically manages configuration for supported clients:

- **Claude Desktop**
  - Config Location: `~/Library/Application Support/Claude/claude_desktop_config.json`
  - Platform: macOS only

- **Cursor**
  - Config Location: `~/.cursor/mcp.json`
  - Platform: macOS only

## Behavior

1. **Config File Creation**:
   - Configuration files are always created for all supported clients
   - Empty configurations are provided when no servers are enabled
   - Directory structure is automatically created if missing

2. **Server Management**:
   - Servers are only included in the configuration when explicitly enabled
   - Required options are validated at configuration time
   - Server-specific validation (e.g., GitLab API URL format) is enforced

3. **Path Handling** (Filesystem Server):
   - Home directory expansion (`~` → `$HOME`)
   - Path normalization (removes duplicate/trailing slashes)
   - Runtime validation of path existence and read permissions
   - Helpful error messages for invalid paths

4. **Platform Validation**:
   - Automatic platform compatibility checking
   - Clear error messages for unsupported configurations

## Example Configurations

### Minimal GitHub Setup
```nix
mcp-servers.servers.github = {
  enable = true;
  access-token = "ghp_your_github_token";
};
```

### Self-hosted GitLab
```nix
mcp-servers.servers.gitlab = {
  enable = true;
  access-token = "glpat_your_gitlab_token";
  api-url = "https://gitlab.company.com/api/v4";
};
```

### Filesystem with Multiple Paths
```nix
mcp-servers.servers.filesystem = {
  enable = true;
  allowed-paths = [
    "~/Documents/Projects"
    "/Users/shared/team-projects"
    "/Applications"
  ];
};
```

### Multiple Servers
```nix
mcp-servers.servers = {
  github.enable = true;
  github.access-token = "ghp_token";

  gitlab = {
    enable = true;
    access-token = "glpat_token";
    api-url = "https://gitlab.company.com/api/v4";
  };

  filesystem = {
    enable = true;
    allowed-paths = ["~/Projects"];
  };
};
```

## License

This project is licensed under the MIT License. See the [LICENSE](./LICENSE) file for details.