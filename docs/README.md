# MCP Servers

MCP (Model Control Protocol) Servers is a framework for managing and configuring model serving infrastructure across different platforms including NixOS, macOS (via nix-darwin), and home-manager configurations.

## Installation

### NixOS

Add the MCP Servers flake to your NixOS configuration:

```nix
{
  inputs.mcp-servers.url = "github:aloshy-ai/nix-mcp-servers";
  
  outputs = { self, nixpkgs, mcp-servers, ... }: {
    nixosConfigurations.your-hostname = nixpkgs.lib.nixosSystem {
      # ...
      modules = [
        mcp-servers.nixosModules.default
        # Your other modules...
        
        # MCP configuration
        {
          services.mcp-clients = {
            enable = true;
            # Configuration options...
          };
        }
      ];
    };
  };
}
```

### macOS (nix-darwin)

Add the MCP Servers flake to your nix-darwin configuration:

```nix
{
  inputs.mcp-servers.url = "github:aloshy-ai/nix-mcp-servers";
  
  outputs = { self, nixpkgs, darwin, mcp-servers, ... }: {
    darwinConfigurations."your-mac" = darwin.lib.darwinSystem {
      # ...
      modules = [
        mcp-servers.darwinModules.default
        # Your other modules...
        
        # MCP configuration
        {
          services.mcp-clients = {
            enable = true;
            # Configuration options...
          };
        }
      ];
    };
  };
}
```

### Home Manager

Add the MCP Servers flake to your Home Manager configuration:

```nix
{
  inputs.mcp-servers.url = "github:aloshy-ai/nix-mcp-servers";
  
  outputs = { self, nixpkgs, home-manager, mcp-servers, ... }: {
    homeConfigurations."your-username" = home-manager.lib.homeManagerConfiguration {
      # ...
      modules = [
        mcp-servers.nixosModules.home-manager  # For NixOS
        # OR
        mcp-servers.darwinModules.home-manager  # For macOS
        
        # Your other modules...
        
        # MCP configuration
        {
          services.mcp-clients = {
            enable = true;
            # Configuration options...
          };
        }
      ];
    };
  };
}
```

## Basic Configuration

Here's a basic example of configuring MCP clients:

```nix
{
  services.mcp-clients = {
    enable = true;
    stateDir = "/var/lib/mcp";  # Default state directory
    
    # Define servers
    servers = {
      "local-server" = {
        host = "localhost";
        port = 8080;
        authToken = "your-auth-token";
      };
    };
    
    # Define clients
    clients = {
      "example-client" = {
        server = "local-server";
        models = [ "llama3" "mistral" ];
        options = {
          # Client-specific options
          maxConcurrentRequests = 4;
        };
      };
    };
  };
}
```

## Advanced Usage

For more advanced configuration options, refer to the [Configuration Options](#options) section.

## Contributing

Contributions to MCP Servers are welcome! Please feel free to submit issues or pull requests on GitHub.

## License

MCP Servers is licensed under the MIT License. See the LICENSE file for details. 