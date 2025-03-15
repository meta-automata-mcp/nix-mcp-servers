{
  lib,
  config,
  pkgs,
  ...
}: let
  namespace = "nix-mcp-servers";
  cfg = config.${namespace}.clients.claude;
in {
  options.${namespace}.clients.claude = with lib.types; {
    enable = lib.mkEnableOption "Enable Claude configuration";
    configPath = lib.mkOption {
      type = nullOr str;
      description = "Path to Claude configuration file";
      default = "${config.${namespace}.configPath}/claude.json";
    };
  };

  config = {};
}
