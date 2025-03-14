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
      type = lib.types.enum ["filesystem" "github"];
      default = "filesystem";
      description = ''
        Type of MCP server. Currently supports:
        - filesystem: Access to local files and directories
        - github: Access to GitHub repositories
      '';
      example = "filesystem";
    };

    command = lib.mkOption {
      type = lib.types.str;
      default = "npx";
      description = ''
        Command to run the MCP server. Usually "npx" for Node.js implementations
        or the full path to a binary for compiled implementations.
      '';
      example = "npx";
    };

    args = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = ''
        Arguments to pass to the MCP server command.
        For filesystem servers, this includes the package name followed by the
        directories you want to allow access to.
      '';
      example = [
        "-y"
        "@modelcontextprotocol/server-filesystem"
        "/home/user/Documents"
        "/home/user/Projects"
      ];
    };

    env = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = ''
        Environment variables to set when running the MCP server.
        Useful for providing API keys or other configuration to the server.
      '';
      example = {
        "GITHUB_PERSONAL_ACCESS_TOKEN" = "ghp_123456789abcdef";
      };
    };

    # Provide some backwards compatibility and convenience
    paths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = ''
        Convenience option for filesystem paths. These will be added to the args.
        For filesystem servers, these are the directories you want to allow access to.
        If you need more control, use the 'args' option directly.
      '';
      example = [
        "/home/user/Documents"
        "/home/user/Projects"
      ];
    };
  };
}
