{ pkgs, lib, ... }:

{
  # This is a simplified approach that doesn't require module evaluation
  system.build.manualHTML = pkgs.callPackage ./manual.nix {
    # Basic options to pass
    options = {};
    revision = "main";
    version = "0.1.0";
  };
}
