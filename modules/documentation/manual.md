# MCP Server Configuration Options {#book-mcp-manual}
## Version @MCP_VERSION@

MCP Flake provides declarative configuration for Model Control Protocol servers and clients.

## Introduction

The MCP Flake allows you to easily manage configuration files for AI model interaction using the Model Control Protocol (MCP). This includes support for clients like Claude Desktop, Cursor IDE, VSCode extensions, and others.

## Features

- Cross-platform support (NixOS, Darwin, home-manager)
- Pure Nix expressions for maximum compatibility
- Declarative configuration with support for secret management
- Support for various MCP servers including filesystem and GitHub servers
- Automatic generation of client configurations at appropriate OS-specific paths

## Configuration Options

```{=include=} options
id-prefix: opt-
list-id: mcp-configuration-variable-list
source: @MCP_OPTIONS_JSON@
```
