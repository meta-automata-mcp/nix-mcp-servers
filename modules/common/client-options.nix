# modules/common/client-options.nix
{lib}: {name, ...}: {
  options = {
    enable = lib.mkEnableOption "this MCP client configuration";

    clientType = lib.mkOption {
      type = lib.types.enum ["claude_desktop"];
      description = ''
        Type of MCP client to configure. Currently supports:
        - claude_desktop: Anthropic's Claude desktop application that uses MCP servers
                          to access local resources
      '';
      example = "claude_desktop";
    };

    configPath = lib.mkOption {
      type = lib.types.str;
      description = ''
        Path to the client configuration file. If not specified, a default
        path will be used based on the client type and operating system.

        For Claude Desktop on:
        - macOS: "~/Library/Application Support/Claude/claude_desktop_config.json"
        - Windows: "%APPDATA%\\Claude\\claude_desktop_config.json"
        - Linux: "~/.config/Claude/claude_desktop_config.json"
      '';
      example = "~/Library/Application Support/Claude/claude_desktop_config.json";
    };

    servers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = ''
        List of MCP server names to use with this client. These names
        should correspond to server configurations defined in the
        `services.mcp-clients.servers` option.

        You can add multiple servers to grant the AI client access to different resources.
        For example, you might want to provide access to both filesystem and other data sources.
      '';
      example = ["filesystem" "github" "google_drive"];
      default = [];
    };
  };
}
