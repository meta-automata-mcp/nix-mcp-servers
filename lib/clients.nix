# lib/clients.nix
{lib}: let
  inherit (lib.platforms) isDarwin getConfigBase;
in {
  # List of supported client types
  supportedTypes = [
    "claude_desktop"
  ];

  # Get default config path for a client based on system
  defaultConfigPath = clientType: system: let
    configBase = getConfigBase system;
  in
    if isDarwin system
    then
      {
        # macOS paths
        "claude_desktop" = "~/Library/Application Support/Claude/mcp-config.json";
      }
      .${clientType}
      or "${configBase}/mcp/${clientType}-config.json"
    else
      {
        # Linux paths
        "claude_desktop" = "${configBase}/claude-desktop/mcp-config.json";
      }
      .${clientType}
      or "${configBase}/mcp/${clientType}-config.json";

  # Generate configuration structure for a specific client type
  generateConfig = {
    clientType,
    servers,
  }:
    if clientType == "claude_desktop"
    then {
      mcpServers = servers;
    }
    else {
      # Generic format, fallback only
      mcpEnabled = true;
      servers = servers;
    };
}
