{
  lib,
  config,
  pkgs,
  ...
}: let
  namespace = "nix-mcp-servers";
in {
  options.${namespace}.servers.filesystem = {
    # Add options here as needed
  };

  config = {};
}
