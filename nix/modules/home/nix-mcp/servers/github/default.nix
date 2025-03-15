{
  options,
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib; let
  cfg = config.${namespace}.servers.github;

  # Simple token validation function
  validateGithubToken = token:
    if builtins.match "^gh[pst]_[A-Za-z0-9_]{36,255}$" token != null
    then token
    else throw "Invalid GitHub token format. Should start with 'ghp_', 'ghs_' or 'gho_' followed by alphanumeric characters.";
in {
  options.${namespace}.servers.github = with types; {
    enable = mkEnableOption "GitHub server";
    command = mkOption {
      type = types.str;
      default = "npx";
      description = "Command to run the GitHub server";
    };
    token = mkOption {
      type = types.str;
      description = "GitHub Personal Access Token";
      apply = token:
        if token == "" || token == "<YOUR_TOKEN>"
        then throw "A valid GitHub Personal Access Token must be provided"
        else validateGithubToken token;
    };
  };

  config = mkIf cfg.enable {
    command = cfg.command;
    args = ["-y" "@modelcontextprotocol/server-github"];
    env = {
      GITHUB_PERSONAL_ACCESS_TOKEN = cfg.token;
    };
  };
}
