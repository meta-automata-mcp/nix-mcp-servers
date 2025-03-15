{
  options,
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib; let
  cfg = config.${namespace}.clients.claude.github;
in {
  options.${namespace}.clients.claude.github = with types; {
    enable = mkEnableOption "GitHub server in claude";
    token = mkOption {
      type = types.str;
      description = "GitHub Personal Access Token";
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
