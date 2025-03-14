{
  pkgs,
  lib,
  inputs,
  ...
}: let
  # Import NMD
  nmdSrc = inputs.nmd;

  # Add NMD to the package set - import the builders.nix file specifically
  nmd = import (nmdSrc + "/builders.nix") {inherit lib pkgs;};

  # We need to directly use the modules-docbook.nix file for creating options XML
  modulesDocBook = import (nmdSrc + "/lib/modules-docbook.nix") {inherit lib pkgs;};

  # Generate documentation for a set of modules
  buildModulesDocs = modules:
    nmd.buildModulesDocs {
      inherit modules;
      moduleRootPaths = [./..];
      mkModuleUrl = path: "https://github.com/aloshy-ai/nix-mcp-servers/blob/main/${path}";
      channelName = "mcp-servers";
      id = "mcp-servers-options";
    };

  # Create a DocBook XML file from the options
  mkOptionsList = options:
    modulesDocBook {
      inherit options;
      transformOptions = opt:
        opt
        // {
          declarations = map (d: d.outPath) (opt.declarations or []);
        };
      # For DocBook output
      id = "mcp-servers-options";
    };

  # Build a documentation site using DocBook
  buildDocBookDocs = {
    modulesDocs,
    docBook,
  }:
    nmd.buildDocBookDocs {
      inherit modulesDocs;
      pathName = "mcp-servers";
      projectName = "MCP Servers";
      documentsDirectory = docBook;
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
    buildModulesDocs
    buildDocBookDocs
    ;
}
