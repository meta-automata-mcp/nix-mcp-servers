# lib/clients.nix
{ lib }:

let
  inherit (lib.platforms) isDarwin getConfigBase;
in
{
  # List of supported client types
  supportedTypes = [
    "claude_desktop"
    "cursor_ide"
    "vscode_extension"
    "browser_extension"
    "system_wide"
  ];
  
  # Get default config path for a client based on system
  defaultConfigPath = clientType: system:
    let
      configBase = getConfigBase system;
    in
    if isDarwin system then
      {
        # macOS paths
        "claude_desktop" = "~/Library/Application Support/Claude/mcp-config.json";
        "cursor_ide" = "~/Library/Application Support/Cursor/User/mcp-config.json";
        "vscode_extension" = "~/Library/Application Support/Code/User/settings.json";
        "browser_extension" = "${configBase}/mcp-browser-extension/config.json";
        "system_wide" = "${configBase}/mcp/config.json";
      }.${clientType} or "${configBase}/mcp/${clientType}-config.json"
    else
      {
        # Linux paths
        "claude_desktop" = "${configBase}/claude-desktop/mcp-config.json";
        "cursor_ide" = "~/.cursor/mcp-config.json";
        "vscode_extension" = "${configBase}/Code/User/settings.json";
        "browser_extension" = "${configBase}/mcp-browser-extension/config.json";
        "system_wide" = "${configBase}/mcp/config.json";
      }.${clientType} or "${configBase}/mcp/${clientType}-config.json";
  
  # Generate configuration structure for a specific client type
  generateConfig = { clientType, servers }:
    if clientType == "claude_desktop" then {
      mcpServers = servers;
    }
    else if clientType == "cursor_ide" then {
      mcpConfig = {
        enabled = true;
        servers = servers;
      };
    }
    else if clientType == "vscode_extension" then {
      "mcp.enabled" = true;
      "mcp.servers" = servers;
    }
    else {
      # Generic format
      mcpEnabled = true;
      servers = servers;
    };
}