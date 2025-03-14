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
    nmd = {
      url = "github:gvolpe/nmd";
      flake = false;
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
        # Import our lib with documentation tools
        mcpLib = import ./lib {
          inherit (pkgs) lib;
          inherit pkgs inputs;
        };

        # Define the modules to document
        moduleList = [
          {imports = [./modules/common];}
        ];

        # Document those modules
        moduleDoc = mcpLib.docs.buildModulesDocs moduleList;

        # Create a DocBook XML file from the options
        optionsXML = mcpLib.docs.mkOptionsList {
          inherit (moduleDoc) options;
          transformOptions = opt:
            opt
            // {
              declarations = map (d: d.outPath) (opt.declarations or []);
            };
        };

        # Create a docBook file
        docBook = pkgs.runCommand "mcp-servers-manual.xml" {} ''
          mkdir -p $out
          cp -r ${./docs}/* $out/
          cp ${optionsXML} $out/options.xml
        '';

        # Build the full documentation
        docs = mcpLib.docs.buildDocBookDocs {
          modulesDocs = [moduleDoc];
          inherit docBook;
        };
      in {
        # CLI tool package
        packages.mcp-setup = pkgs.writeShellScriptBin "mcp-setup" ''
          echo "MCP Setup CLI"
          echo "This tool configures MCP clients based on your NixOS/Darwin configuration."
        '';

        # Documentation package - we choose the HTML output for the main docs
        packages.docs = docs.html;

        # Also make other formats available
        packages.docs-json = moduleDoc.json;
        packages.docs-man-pages = docs.manPages;
        packages.manual-combined = docs.manualCombined;
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
