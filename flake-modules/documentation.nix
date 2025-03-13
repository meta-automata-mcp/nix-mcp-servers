# flake-modules/documentation.nix - Documentation generator for MCP servers options
{
  self,
  lib,
  config,
  flake-parts-lib,
  ...
}: {
  options = {
    # Documentation options can be added here if needed
  };

  config = {
    perSystem = {
      system,
      pkgs,
      ...
    }: {
      # Generate documentation package
      packages.docs = pkgs.writeTextFile {
        name = "mcp-servers-options-docs";
        text =
          builtins.toJSON
          (
            lib.evalModules {
              modules = [
                {imports = [../modules/common/options.nix];}
                {_module.check = false;}
              ];
            }
          )
          .options
          .services
          .mcp-clients;
        destination = "/share/doc/mcp-servers/options.json";
      };

      # Add a script to view the documentation
      apps.view-docs = {
        type = "app";
        program =
          toString
          (pkgs.writeShellScriptBin "view-mcp-options" ''
            ${pkgs.jq}/bin/jq -r . ${self.packages.${system}.docs}/share/doc/mcp-servers/options.json | ${pkgs.less}/bin/less
          '')
          .outPath
          + "/bin/view-mcp-options";
      };
    };
  };
}
