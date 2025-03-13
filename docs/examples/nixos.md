# NixOS Example

This example demonstrates how to use the MCP servers module with NixOS.

## Basic Configuration

```nix
{
  inputs.mcp-servers.url = "github:aloshy-ai/nix-mcp-servers";
  
  outputs = { self, nixpkgs, mcp-servers, ... }: {
    nixosConfigurations.hostname = nixpkgs.lib.nixosSystem {
      # system is usually auto-detected with hardware-configuration.nix
      system = "x86_64-linux";
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

## Advanced Configuration

For more advanced configuration options, refer to the [module options documentation](../modules/options.md). 