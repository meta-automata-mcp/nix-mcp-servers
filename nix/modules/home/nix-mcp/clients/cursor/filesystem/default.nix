{
  options,
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.clients.cursor.filesystem;
in {
  options.${namespace}.clients.cursor.filesystem = with types; {
    enable = mkBoolOpt false "Whether or not to enable the filesystem server in cursor.";
    paths = mkOption {
      type = types.listOf types.str;
      description = "Paths to expose via the filesystem server (at least one required)";
      example = ["/Users/username/Desktop" "/path/to/other/allowed/dir"];
      default = [];
    };
  };

  config = mkIf cfg.enable {
    ${namespace}.servers.filesystem = {
      enable = true;
      paths = cfg.paths;
    };
  };
}
