# lib/paths.nix
{lib}: {
  # Expand ~ to concrete home path
  expandHome = {
    path,
    homeDirectory ? "/home/PLACEHOLDER",
  }:
    builtins.replaceStrings ["~"] [homeDirectory] path;

  # Get directory portion of a path
  dirname = path: let
    components = lib.splitString "/" path;
    parentComponents = lib.take (lib.length components - 1) components;
  in
    if lib.hasPrefix "/" path
    then "/${lib.concatStringsSep "/" parentComponents}"
    else lib.concatStringsSep "/" parentComponents;

  # Get relative path for home-manager (strip home directory prefix)
  stripHomePrefix = {
    path,
    homeDirectory,
  }: let
    expanded =
      if lib.hasPrefix "~" path
      then builtins.replaceStrings ["~"] [homeDirectory] path
      else path;
  in
    if lib.hasPrefix homeDirectory expanded
    then lib.removePrefix (homeDirectory + "/") expanded
    else expanded;
}
