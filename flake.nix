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

  outputs = inputs:
  # This is an example and in your actual flake you can use `snowfall-lib.mkFlake` directly unless you explicitly need a feature of `lib`.
  let
    lib = inputs.snowfall-lib.mkLib {
      # You must pass in both your flake's inputs and the root directory of your flake.
      inherit inputs;
      # The `src` must be the root of the flake. See configuration in the next section for information on how you can move your Nix files to a separate directory.
      src = ./.;
      # You can optionally place your Snowfall-related files in another directory.
      snowfall.root = ./nix;

      snowfall = {
        namespace = "nix-mcp";
        meta = {
          # Your flake's preferred name in the flake registry.
          name = "nix-mcp";
          # A pretty name for your flake.
          title = "Nix MCP";
        };
      };

      # The outputs builder receives an attribute set of your available NixPkgs channels. These are every input that points to a NixPkgs instance (even forks). In this case, the only channel available in this flake is `channels.nixpkgs`.
      outputs-builder = channels: {
        # Outputs in the outputs builder are transformed to support each system. This entry will be turned into multiple different outputs like `formatter.x86_64-linux.*`.
        formatter = channels.nixpkgs.alejandra;
      };
    };
  in
    lib.mkFlake {
      alias = {
        packages.default = "docs";
        modules = {
          darwin.default = "nix-mcp";
          home.default = "nix-mcp";
        };
      };

      outputs-builder = channels: {formatter = channels.nixpkgs.alejandra;};
    };
}
