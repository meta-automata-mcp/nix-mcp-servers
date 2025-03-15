{
  lib,
  config,
  pkgs,
  namespace,
  ...
}: let
  cfg = config.${namespace}.clients.cursor;
in {
  options.${namespace}.clients.cursor = with lib.types; {
    enable = lib.mkEnableOption "Enable Cursor configuration";
    configPath = lib.mkOption {
      type = nullOr str;
      description = "Path to Cursor configuration file";
      default = "${config.${namespace}.configPath}/cursor.json";
    };
  };

  config = {};
}
