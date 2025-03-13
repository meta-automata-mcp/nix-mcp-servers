# Darwin Example

This example demonstrates how to use the MCP servers module with nix-darwin.

## Basic Configuration

```nix
{
  inputs.mcp-servers.url = "github:aloshy-ai/nix-mcp-servers";
  
  outputs = { self, nixpkgs, darwin, mcp-servers, ... }: {
    darwinConfigurations.macbook = darwin.lib.darwinSystem {
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
              path = "~/Documents/models";
              credentials.apiKey = "not-needed";
            };
            clients.claude = {
              enable = true;
              clientType = "claude_desktop";
              # configPath will default to ~/Library/Application Support/Claude/mcp-config.json
            };
          };
        }
      ];
    };
  };
}
```

## Advanced Configuration

For more advanced configuration options, refer to the [module options documentation](../modules/options.md). 