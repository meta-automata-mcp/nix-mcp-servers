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
  cfg = config.${namespace}.clients.claude;
in {
  options.${namespace}.clients.claude = with types; {
    filesystem = mkEnableOption "Filesystem";

    token = mkOption {
      type = types.str.isRequired;
      description = "GitHub Personal Access Token";
      example = "ghp_1234567890abcdef1234567890abcdef12345678";
      default = "";
    };
  };