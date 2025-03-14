{
  pkgs,
  lib,
  ...
}: {
  # Build the manual using our dynamic options-doc module
  system.build.manualHTML = pkgs.callPackage ./options-doc.nix {
    inherit lib;
    # Version will be dynamically determined
  };
}
