# modules/documentation/eval-docs.nix
{ system, pkgs, mcpLib, revision, version }:

let
  localPkgs = pkgs;
  
  # Create minimal module evaluation
  eval = localPkgs.lib.evalModules {
    modules = [
      ./default.nix
      {
        imports = [
          ../common/options.nix
          ../common/server-options.nix
          ../common/client-options.nix
        ];
        
        # Set required configuration values
        services.mcp-clients = {
          enable = true;
          version = version;
          revision = revision;
        };
        documentation.enable = true;
        
        # Set the system type
        nixpkgs.system = system;
      }
    ];
    
    # Pass required special arguments
    specialArgs = {
      modulesPath = builtins.toString ../..;
      pkgs = localPkgs;
      lib = localPkgs.lib;
    };
  };

in
  # Return the documentation derivations
  eval.config.system.build.manual
