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

    apiKey = lib.mkOption {
      type = nullOr str;
      description = "API key for Claude service";
      default = null;
    };

    model = lib.mkOption {
      type = str;
      description = "Claude model to use";
      default = "claude-3-opus-20240229";
    };

    useFilesystemServer = lib.mkOption {
      type = bool;
      description = "Whether to use the filesystem server for file access";
      default = false;
    };

    allowedDirectories = lib.mkOption {
      type = listOf str;
      description = "List of directories that Claude is allowed to access";
      default = [];
    };
  };

  config = lib.mkIf cfg.enable {
    # Generate the Claude configuration file
    home.file.${cfg.configPath} = lib.mkIf (cfg.configPath != null) {
      text = builtins.toJSON {
        apiKey = cfg.apiKey;
        model = cfg.model;
        useFilesystemServer = cfg.useFilesystemServer;
      };
    };

    # Configure filesystem server for Claude if enabled
    ${namespace}.servers.filesystem = lib.mkIf cfg.useFilesystemServer {
      enable = true;
      clientMappings = {
        claude = cfg.allowedDirectories;
      };
    };
  };
}
