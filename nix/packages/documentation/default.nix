{
  inputs,
  self,
  lib,
  pkgs,
  ...
}: {
  flake = let
    # Manual builder from our options-doc module
    docs = pkgs.callPackage ./options-doc.nix {
      lib = pkgs.lib;
      revision = self.rev or "main";
      version = "0.1.0";
    };
  in {
    # Documentation output
    packages.docs = docs;

    # Set docs as the default package
    packages.default = docs;
  };
}
