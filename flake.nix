{
  description = "MCP server configuration management for various clients";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-parts,
    home-manager,
    darwin,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];

      perSystem = {
        system,
        pkgs,
        ...
      }: {
        # Simplified package definition
        packages.default = pkgs.writeShellScriptBin "mcp-setup" ''
          echo "MCP Setup CLI"
          echo "=============="
          echo "This tool configures MCP clients based on your NixOS/Darwin configuration."
        '';
      };

      flake = {
        lib = import ./lib {
          inherit (nixpkgs) lib;
        };

        nixosModules = {
          default = {...}: {
            imports = [
              ./modules/common.nix
              ./modules/nixos.nix
            ];
          };

          home-manager = {...}: {
            imports = [
              ./modules/common.nix
              ./modules/home-manager.nix
            ];
          };
        };

        darwinModules = {
          default = {...}: {
            imports = [
              ./modules/common.nix
              ./modules/darwin.nix
            ];
          };

          home-manager = {...}: {
            imports = [
              ./modules/common.nix
              ./modules/home-manager.nix
            ];
          };
        };
      };
    };
}
