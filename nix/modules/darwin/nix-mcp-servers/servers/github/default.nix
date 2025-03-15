{
  lib,
  config,
  pkgs,
  namespace,
  ...
}: {
  options.${namespace}.servers.github = {
    # Add options here as needed
  };

  config = {};
}
