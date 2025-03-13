# Darwin Example

This example demonstrates how to use the MCP servers module with nix-darwin.

## Basic Configuration

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    mcp-servers.url = "github:aloshy-ai/nix-mcp-servers";
  };

  outputs = { self, nixpkgs, darwin, mcp-servers, ... }: {
    darwinConfigurations.hostname = darwin.lib.darwinSystem {
      # Your system architecture
      system = "aarch64-darwin";
      modules = [
        mcp-servers.darwinModules.default
        {
          services.mcp-clients = {
            enable = true;
            servers.local_models = {
              enable = true;
              name = "Local Models";
              type = "filesystem";
              path = "/Users/username/models";
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

## Alternative Import Method

You can also import the module directly using:

```nix
{
  imports = [
    (builtins.fetchTarball "https://github.com/aloshy-ai/nix-mcp-servers/archive/main.tar.gz").darwinModules.default
  ];

  services.mcp-clients = {
    enable = true;
    # ... configuration ...
  };
}
```

## Advanced Configuration

For more advanced configuration options, refer to the [module options documentation](../modules/options.md).
