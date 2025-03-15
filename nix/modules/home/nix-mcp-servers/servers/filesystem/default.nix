{
  lib,
  config,
  pkgs,
  namespace,
  ...
}: {
  options.${namespace}.servers.filesystem = {
    # Add options here as needed
  };

  config = {};
}
