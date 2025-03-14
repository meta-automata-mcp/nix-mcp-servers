# lib/clients.nix
{ lib }: let
  inherit (lib.platforms) isDarwin getConfigBase;
in {
  # List of supported client types
  supportedTypes = [
    "claudeDesktop"
    "cursor"
  ];

  # Get default config path for a client based on system
  defaultConfigPath = clientType: system: let
    configBase = getConfigBase system;
  in
    if isDarwin system
    then
      {
        # macOS paths
        "claudeDesktop" = "~/Library/Application Support/Claude/claude_desktop_config.json";
        "cursor" = "${configBase}/Cursor/mcp-config.json";
      }
      .${clientType}
      or "${configBase}/mcp/${clientType}-config.json"
    else
      {
        # Linux paths
        "claudeDesktop" = "${configBase}/Claude/claude_desktop_config.json";
        "cursor" = "${configBase}/Cursor/mcp-config.json";
      }
      .${clientType}
      or "${configBase}/mcp/${clientType}-config.json";

  # Generate configuration structure for a specific client type
  generateConfig = {
    clientType,
    servers,
  }:
    if clientType == "claudeDesktop"
    then {
      # Claude Desktop expects mcpServers with key as server name
      # and value as the server configuration
      mcpServers = servers;
    }
    else if clientType == "cursor"
    then {
      # Cursor has the same format as Claude Desktop
      mcpServers = servers;
    }
    else {
      # Generic format, fallback only
      mcpEnabled = true;
      servers = servers;
    };
}