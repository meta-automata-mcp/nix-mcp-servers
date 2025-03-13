# NixOS Example

This example demonstrates how to use the MCP servers module with NixOS.

## Basic Configuration

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    mcp-servers.url = "github:aloshy-ai/nix-mcp-servers";
  };

  outputs = { self, nixpkgs, mcp-servers, ... }: {
    nixosConfigurations.hostname = nixpkgs.lib.nixosSystem {
      # Your system architecture
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

## Alternative Import Method

You can also import the module directly using:

```nix
{
  imports = [
    (builtins.fetchTarball "https://github.com/aloshy-ai/nix-mcp-servers/archive/main.tar.gz").nixosModules.default
  ];

  services.mcp-clients = {
    enable = true;
    # ... configuration ...
  };
}
```

## Advanced Configuration

For more advanced configuration options, refer to the [module options documentation](../modules/options.md).
