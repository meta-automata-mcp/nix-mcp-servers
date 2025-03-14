# modules/common/server-options.nix
{lib}: {name, ...}: {
  options = {
    enable = lib.mkEnableOption "this MCP server configuration";

    name = lib.mkOption {
      type = lib.types.str;
      default = name;
      description = ''
        User-friendly name for this server. This will be displayed in client
        interfaces when connecting to the server.
      '';
      example = "Local Filesystem Access";
    };

    type = lib.mkOption {
      type = lib.types.enum ["filesystem"];
      default = name;
      description = ''
        Type of MCP server. Currently supports:
        - filesystem: Access to local files and directories
      '';
      example = "filesystem";
    };

    baseUrl = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Base URL for the API (optional). For filesystem type, this is not used
        and can be left as null.
      '';
      example = "http://localhost:8000/api";
    };

    paths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = ''
        List of filesystem paths that the MCP server is allowed to access.
        These should be absolute paths to directories you want to grant access to.
        The AI client will only be able to read/write files within these directories.
      '';
      example = [
        "/home/user/Documents"
        "/home/user/Projects"
      ];
    };

    command = lib.mkOption {
      type = lib.types.str;
      default = "npx";
      description = ''
        Command to run the MCP server. For the Node.js implementation, use "npx".
        For the Go implementation, specify the full path to the binary.
      '';
      example = "npx";
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = ["-y" "@modelcontextprotocol/server-filesystem"];
      description = ''
        Additional arguments to pass to the MCP server command.
        For the default npx command, these normally include the package name.
      '';
      example = ["-y" "@modelcontextprotocol/server-filesystem"];
    };
  };
}
