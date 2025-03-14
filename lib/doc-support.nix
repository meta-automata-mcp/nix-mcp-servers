{
  pkgs,
  lib,
  inputs,
  ...
}: let
  # Import NMD
  nmdSrc = inputs.nmd;

  # Add NMD to the package set
  nmd = import nmdSrc {inherit lib pkgs;};

  # Helper functions for documentation
  mkOptionsList = pkgs.callPackage (nmdSrc + "/lib/options-to-docbook.nix") {};

  # Custom evaluator for modules
  evalModules = modules:
    lib.evalModules {
      inherit modules;
      specialArgs = {inherit pkgs;};
    };

  # Generate documentation for a set of modules
  buildModulesDocs = modules:
    nmd.buildModulesDocs {
      inherit modules;
      moduleRootPaths = [./..];
      mkModuleUrl = path: "https://github.com/aloshy-ai/nix-mcp-servers/blob/main/${path}";
      channelName = "mcp-servers";
    };

  # Build a documentation site using DocBook
  buildDocBookDocs = {
    modulesDocs,
    docBook,
  }:
    nmd.buildDocBookDocs {
      inherit docBook;
      pathName = "mcp-servers";
      projectName = "MCP Servers";
      modulesDocs = modulesDocs;
      documentsDirectory = ./.;
      documentType = "book";
      chunkToc = ''
        <toc>
          <d:tocentry xmlns:d="http://docbook.org/ns/docbook" linkend="book-mcp-servers-manual"><?dbhtml filename="index.html"?>
            <d:tocentry linkend="ch-options"><?dbhtml filename="options.html"?></d:tocentry>
            <d:tocentry linkend="ch-guides"><?dbhtml filename="guides.html"?></d:tocentry>
            <d:tocentry linkend="ch-release-notes"><?dbhtml filename="release-notes.html"?></d:tocentry>
          </d:tocentry>
        </toc>
      '';
    };
in {
  inherit
    nmd
    mkOptionsList
    evalModules
    buildModulesDocs
    buildDocBookDocs
    ;
}
