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
  cfg = config.${namespace}.servers.github;
in {
  options.${namespace}.servers.github = with types; {
    enable = mkBoolOpt false "Whether or not to enable the GitHub server.";
    command = mkOption {
      type = types.str;
      default = "npx";
      description = "Command to run the GitHub server";
    };
    token = mkOption {
      type = types.str.isRequired;
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
