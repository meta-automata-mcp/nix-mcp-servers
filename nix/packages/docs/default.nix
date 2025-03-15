{
  lib,
  pkgs,
  ...
}:
# Manual builder from our options-doc module
pkgs.callPackage ./options-doc.nix {
  lib = pkgs.lib;
  revision = "main";
  version = "0.1.0";
}
