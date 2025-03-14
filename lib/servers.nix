# lib/servers.nix
{lib}: {
  # List of supported server types
  supportedTypes = [
    "filesystem"
    "github"
  ];

  # Format server configuration for the Claude desktop client
  formatForClient = {
    server,
    clientType,
  }:
    if clientType == "claude_desktop"
    then
      # Format according to MCP standards with command, args, and env
      {
        command = server.command;
        args = server.args;
      }
      // (
        if server.env != {}
        then {env = server.env;}
        else {}
      )
    else
      # Generic fallback format
      {
        command = server.command;
        args = server.args;
      }
      // (
        if server.env != {}
        then {env = server.env;}
        else {}
      );
}
