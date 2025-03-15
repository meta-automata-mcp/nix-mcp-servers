{
  options,
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib; let
  cfg = config.${namespace}.clients.claude.filesystem;
in {
  options.${namespace}.clients.claude.filesystem = with types; {
    enable = mkEnableOption "filesystem server in claude";
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
