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

  # Format server configuration for specific client types
  formatForClient = {
    server,
    clientType,
  }:
    if clientType == "claude_desktop"
    then {
      name = "${server.name} API";
      type = server.type;
      apiKey = server.credentials.apiKey;
      baseUrl = server.baseUrl or lib.servers.defaultBaseUrls.${server.type} or null;
      # For filesystem type, add path parameter for model directory
      path =
        if server.type == "filesystem"
        then server.path or (throw "Path must be specified for filesystem server type")
        else null;
    }
    else {
      # Generic format (fallback only)
      name = server.name;
      type = server.type;
      apiKey = server.credentials.apiKey;
      baseUrl = server.baseUrl or lib.servers.defaultBaseUrls.${server.type} or null;
      path =
        if server.type == "filesystem"
        then server.path or (throw "Path must be specified for filesystem server type")
        else null;
    };
}
