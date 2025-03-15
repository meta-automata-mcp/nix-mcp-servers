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
  cfg = config.${namespace}.servers.filesystem;
in {
  options.${namespace}.servers.filesystem = with types; {
    enable = mkBoolOpt false "Whether or not to enable the filesystem server.";
    command = mkOption {
      type = types.str;
      default = "npx";
      description = "Command to run the filesystem server";
    };
    paths = mkOption {
      type = types.listOf types.str;
      description = "Paths to expose via the filesystem server (at least one required)";
      default = [];
      apply = paths:
        if paths == []
        then throw "At least one valid path must be provided"
        else if !all (path: pathExists path && !hasInfix "placeholder" path) paths
        then throw "All paths must exist and not contain placeholder text"
        else paths;
    };
  };

  config = mkIf cfg.enable {
    command = cfg.command;
    args = ["-y" "@modelcontextprotocol/server-filesystem"] ++ cfg.paths;
  };
}
