# lib/servers.nix
{lib}: {
  # List of supported server types
  supportedTypes = [
    "filesystem"
  ];

  # Default base URLs for known services
  defaultBaseUrls = {
    filesystem = null; # FileSystem doesn't need a base URL
  };

  # Format server configuration for the Claude desktop client
  formatForClient = {
    server,
    clientType,
  }:
    if clientType == "claude_desktop"
    then {
      # For filesystem type, create the server configuration for Claude Desktop
      command = server.command or "npx";
      args =
        (server.extraArgs or ["-y" "@modelcontextprotocol/server-filesystem"])
        ++ (server.paths or []);
    }
    else {
      # Generic format (fallback only)
      command = server.command or "npx";
      args =
        (server.extraArgs or ["-y" "@modelcontextprotocol/server-filesystem"])
        ++ (server.paths or []);
    };
}
