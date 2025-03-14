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
        args =
          if server.type == "filesystem" && server.paths != []
          then
            # Add default args for filesystem server if not already specified
            (
              if server.args == []
              then ["-y" "@modelcontextprotocol/server-filesystem"]
              else server.args
            )
            ++ server.paths
          else server.args;
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
        args =
          if server.type == "filesystem" && server.paths != []
          then
            # Add default args for filesystem server if not already specified
            (
              if server.args == []
              then ["-y" "@modelcontextprotocol/server-filesystem"]
              else server.args
            )
            ++ server.paths
          else server.args;
      }
      // (
        if server.env != {}
        then {env = server.env;}
        else {}
      );
}
