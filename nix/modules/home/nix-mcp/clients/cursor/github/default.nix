{
  options,
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.clients.cursor.github;
in {
  options.${namespace}.clients.cursor.github = with types; {
    enable = mkBoolOpt false "Whether or not to enable the github server in cursor.";
    token = mkOption {
      type = types.str.isRequired;
      description = "GitHub Personal Access Token";
      example = "ghp_1234567890abcdef1234567890abcdef12345678";
      default = "";
    };
  };

  config = mkIf cfg.enable {
    ${namespace}.servers.github = {
      enable = true;
      token = cfg.token;
    };
  };
}
