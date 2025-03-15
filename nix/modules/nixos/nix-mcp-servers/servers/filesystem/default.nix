{
  options,
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib; let
  cfg = config.${namespace}.servers.filesystem;
in {
  options.${namespace}.servers.filesystem = with types; {
    enable = mkEnableOption "filesystem server";
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
    args = mkOption {
      type = types.listOf types.str;
      description = "Arguments to pass to the filesystem server command";
      default = ["-y" "@modelcontextprotocol/server-filesystem"];
    };
  };

  config = mkIf cfg.enable {
    ${namespace}.servers.filesystem.args = cfg.args ++ cfg.paths;
  };
}
