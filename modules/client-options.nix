# modules/client-options.nix
{lib}: {name, ...}: {
  options = {
    enable = lib.mkEnableOption "this MCP client";

    clientType = lib.mkOption {
      type = lib.types.enum ["claude_desktop"];
      description = "Type of MCP client";
      example = "claude_desktop";
    };

    configPath = lib.mkOption {
      type = lib.types.str;
      description = "Path to the client configuration file";
      example = "~/Library/Application Support/Claude/mcp-config.json";
    };

    servers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "List of MCP servers to use with this client";
      example = ["filesystem"];
      default = [];
    };
  };
}
