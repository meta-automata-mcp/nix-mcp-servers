{
  lib,
  inputs,
  snowfall-inputs,
}: rec {
  ## Override a package's metadata
  ##
  ## ```nix
  ## let
  ##  new-meta = {
  ##    description = "My new description";
  ##  };
  ## in
  ##  lib.override-meta new-meta pkgs.hello
  ## ```
  ##
  #@ Attrs -> Package -> Package
  override-meta = meta: package:
    package.overrideAttrs (attrs: {
      meta = (attrs.meta or {}) // meta;
    });

  # Import modules lib
  modules = import ./modules {inherit lib;};

  # Re-export all module functions at the top level
  inherit
    (modules)
    mkOpt
    mkOpt'
    mkBoolOpt
    mkBoolOpt'
    enabled
    disabled
    ;
}
