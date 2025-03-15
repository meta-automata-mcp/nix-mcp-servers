{
  lib,
  config,
  pkgs,
  ...
}: let
  namespace = "nix-mcp-servers";
  cfg = config.${namespace}.servers.filesystem;
in {
  options.${namespace}.servers.filesystem = with lib.types; {
    enable = lib.mkEnableOption "Enable filesystem server configuration";

    configPath = lib.mkOption {
      type = nullOr str;
      description = "Path to filesystem server configuration file";
      default = "${config.${namespace}.configPath}/filesystem-server.json";
    };

    allowedDirectories = lib.mkOption {
      type = listOf str;
      description = "List of directories that are allowed to be accessed";
      default = [];
      example = ["/Users/username/Projects" "/Users/username/Documents"];
    };

    defaultPermissions = lib.mkOption {
      type = enum ["read" "write" "read-write"];
      description = "Default permissions for allowed directories";
      default = "read";
    };

    clientMappings = lib.mkOption {
      type = attrsOf (listOf str);
      description = "Mapping of client names to their allowed directories";
      default = {};
      example = {
        claude = ["/Users/username/Projects"];
        cursor = ["/Users/username/Documents"];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Generate the filesystem server configuration file
    home.file.${cfg.configPath} = lib.mkIf (cfg.configPath != null) {
      text = builtins.toJSON {
        allowedDirectories = cfg.allowedDirectories;
        defaultPermissions = cfg.defaultPermissions;
        clientMappings = cfg.clientMappings;
      };
    };
  };
}
