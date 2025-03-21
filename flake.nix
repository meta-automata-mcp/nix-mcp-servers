{
  description = "Declarative MCP Server Configuration Generator";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: let
    lib = inputs.snowfall-lib.mkLib {
      inherit inputs;
      src = ./.;

      snowfall = {
        root = ./nix;
        namespace = "nix-mcp-servers";
        meta = {
          name = "nix-mcp-servers";
          title = "Nix MCP Servers";
        };
      };
    };
  in
    lib.mkFlake {
      channels-config = {
        allowUnfree = true;
      };

      alias = {
        packages.default = "docs";
        modules.nixos.default = "nix-mcp-servers";
        modules.darwin.default = "nix-mcp-servers";
        modules.home.default = "nix-mcp-servers";
      };

      outputs-builder = channels: {
        formatter = channels.nixpkgs.alejandra;
      };
    };
}
