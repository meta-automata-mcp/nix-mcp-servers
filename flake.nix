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
      }: let
        mcp-setup = pkgs.writeShellScriptBin "mcp-setup" ''
          echo "MCP Setup CLI"
          echo "This tool configures MCP clients based on your NixOS/Darwin configuration."
        '';
        
        # Manual builder from our options-doc module
        manualHTML = pkgs.callPackage ./modules/documentation/options-doc.nix {
          lib = pkgs.lib;
          revision = self.rev or "main"; 
          version = "0.1.0";
        };
      in {
        # CLI tool package
        packages.mcp-setup = mcp-setup;

        # Set the default package
        packages.default = mcp-setup;
        
        # Documentation output
        packages.manualHTML = manualHTML;
      };

      flake = {
        lib = import ./lib {
          inherit (nixpkgs) lib;
        };

        nixosModules = {
          default = {...}: {
            imports = [
              ./modules/common
              ./modules/nixos
            ];
          };

          home-manager = {...}: {
            imports = [
              ./modules/common
              ./modules/home-manager
            ];
          };
        };

        darwinModules = {
          default = {...}: {
            imports = [
              ./modules/common
              ./modules/darwin
            ];
          };

          home-manager = {...}: {
            imports = [
              ./modules/common
              ./modules/home-manager
            ];
          };
        };
      };
    };
}
