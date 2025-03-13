# MCP Servers Module Options

This document provides a reference for all the available options in the MCP servers modules.

## General Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `services.mcp-clients.enable` | boolean | `false` | Whether to enable the MCP clients service |
| `services.mcp-clients.stateDir` | string | `~/.local/state/mcp-setup` or `/var/lib/mcp-setup` | Directory to store MCP configuration state |

## Server Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `services.mcp-clients.servers.<name>.enable` | boolean | `false` | Whether to enable this MCP server |
| `services.mcp-clients.servers.<name>.name` | string | name attribute | User-friendly name for this server |
| `services.mcp-clients.servers.<name>.type` | enum | name attribute | Type of MCP server (filesystem) |
| `services.mcp-clients.servers.<name>.baseUrl` | string or null | `null` | Base URL for the API (optional) |
| `services.mcp-clients.servers.<name>.path` | string or null | `null` | File system path for filesystem server type |
| `services.mcp-clients.servers.<name>.credentials.apiKey` | string | | API key for authentication |

## Client Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `services.mcp-clients.clients.<name>.enable` | boolean | `false` | Whether to enable this MCP client |
| `services.mcp-clients.clients.<name>.clientType` | enum | name attribute | Type of MCP client (claude_desktop) |
| `services.mcp-clients.clients.<name>.configPath` | string | platform-dependent | Path to the client configuration file |
| `services.mcp-clients.clients.<name>.servers` | list of strings | all enabled servers | List of MCP servers to use with this client |

---

*Note: This documentation is automatically generated from the module options declarations. For the most up-to-date information, you can run `nix run github:aloshy-ai/nix-mcp-servers#view-docs`.*
