# modules/documentation/options-doc.nix
{ pkgs, options, version, revision ? "main" }:

with pkgs;

let
  lib = pkgs.lib;
  
  # Transform declarations to GitHub links
  gitHubDeclaration = subpath: {
    url = "https://github.com/aloshy-ai/nix-mcp-servers/blob/${revision}/${subpath}";
    name = "<mcp-servers/${subpath}>";
  };
  
  # Generate options documentation
  optionsDoc = buildPackages.nixosOptionsDoc {
    inherit options;
    transformOptions = opt: opt // {
      # Clean up declaration sites to link to GitHub
      declarations = map (decl:
        if lib.hasPrefix (toString ../.) (toString decl) then
          gitHubDeclaration
            (lib.removePrefix "/" (lib.removePrefix (toString ../.) (toString decl)))
        else decl
      ) opt.declarations;
    };
  };

in rec {
  # JSON options for API consumption
  optionsJSON = runCommand "mcp-options.json" 
    { meta.description = "MCP Servers options in JSON format"; }
    ''
      mkdir -p $out/{share/doc,nix-support}
      cp -a ${optionsDoc.optionsJSON}/share/doc/nixos $out/share/doc/mcp
      substitute \
        ${optionsDoc.optionsJSON}/nix-support/hydra-build-products \
        $out/nix-support/hydra-build-products \
        --replace-fail \
          '${optionsDoc.optionsJSON}/share/doc/nixos' \
          "$out/share/doc/mcp"
    '';

  # HTML manual 
  manualHTML = runCommand "mcp-manual-html"
    { 
      nativeBuildInputs = [ buildPackages.nixos-render-docs ];
      styles = lib.sourceFilesBySuffices (pkgs.path + "/doc") [ ".css" ];
      meta.description = "The MCP Servers Configuration Manual";
      allowedReferences = ["out"];
    }
    ''
      # Generate the HTML manual
      dst=$out/share/doc/mcp
      mkdir -p $dst
      
      # Copy styles and syntax highlighting
      cp $styles/style.css $dst
      cp -r ${pkgs.documentation-highlighter} $dst/highlightjs
      
      # Process markdown template
      substitute ${./manual.md} manual.md \
        --replace-fail '@MCP_VERSION@' "${version}" \
        --replace-fail '@MCP_OPTIONS_JSON@' ${optionsJSON}/share/doc/mcp/options.json
      
      # Check if nixos-render-docs supports redirects
      if nixos-render-docs manual html --help | grep --silent -E '^\s+--redirects\s'; then
        redirects_opt="--redirects ${./redirects.json}"
      fi
      
      # Build HTML
      nixos-render-docs -j $NIX_BUILD_CORES manual html \
        --manpage-urls ${pkgs.writeText "manpage-urls.json" "{}"} \
        --revision ${lib.escapeShellArg revision} \
        --generator "nixos-render-docs ${lib.version}" \
        $redirects_opt \
        --stylesheet style.css \
        --stylesheet highlightjs/mono-blue.css \
        --script ./highlightjs/highlight.pack.js \
        --script ./highlightjs/loader.js \
        --toc-depth 1 \
        --chunk-toc-depth 1 \
        ./manual.md \
        $dst/index.html
      
      mkdir -p $out/nix-support
      echo "nix-build out $out" >> $out/nix-support/hydra-build-products
      echo "doc manual $dst" >> $out/nix-support/hydra-build-products
    '';

  # Index page of the manual
  manualHTMLIndex = "${manualHTML}/share/doc/mcp/index.html";
}
