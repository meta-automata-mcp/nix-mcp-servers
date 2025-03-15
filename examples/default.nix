# Example usage of the MCP clients and servers
{
  namespace,
  pkgs,
  ...
}: {
  # Enable Claude with filesystem access
  ${namespace}.clients.claude = {
    enable = true; # Enable the Claude client
  };

  ${namespace}.clients.claude.filesystem = {
    enable = true; # Enable filesystem access for Claude
    paths = [
      # Add paths you want Claude to access
      "/Users/username/projects"
      "/Users/username/Documents"
    ];
  };

  # Enable Cursor with both filesystem and GitHub access
  ${namespace}.clients.cursor = {
    enable = true; # Enable the Cursor client
  };

  ${namespace}.clients.cursor.filesystem = {
    enable = true; # Enable filesystem access for Cursor
    paths = [
      # Add paths you want Cursor to access
      "/Users/username/projects"
      "/Users/username/Documents"
    ];
  };

  ${namespace}.clients.cursor.github = {
    enable = true; # Enable GitHub access for Cursor
    token = "ghp_yourgithubtoken123456789"; # Replace with your GitHub token
  };

  # You can also configure the servers directly
  # Note: The clients above will automatically enable the corresponding servers
  # These settings will be merged with the client settings
  ${namespace}.servers.filesystem = {
    # You can add additional configuration here
  };

  ${namespace}.servers.github = {
    # You can add additional configuration here
  };
}
