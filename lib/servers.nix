# lib/servers.nix
{ lib }: {
  # List of supported server types
  supportedTypes = [
    "filesystem"
    "github"
  ];

  # Format server configuration for client
  formatForClient = { server, clientType, serverName }:
    if server.type == "filesystem" then
      # Handle filesystem server
      {
        command = server.command;
        args = server.filesystem.args ++ server.filesystem.extraArgs;
      } 
      // (if server.env != {} then { env = server.env; } else {})
    else if server.type == "github" then
      # Handle GitHub server
      {
        command = server.command;
        args = [ "-y" "@modelcontextprotocol/server-github" ];
      } 
      // (if server.env != {} then { env = server.env; } else {})
    else
      # Generic fallback format
      {
        command = server.command;
        args = [];
      }
      // (if server.env != {} then { env = server.env; } else {});
}