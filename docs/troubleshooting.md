# Troubleshooting

This document provides solutions for common issues you might encounter when using the MCP FileSystem server with Claude Desktop.

## Configuration Issues

### Configuration File Not Being Created

**Symptom**: The configuration file is not being created in the expected location after running `nixos-rebuild`, `darwin-rebuild`, or `home-manager switch`.

**Possible Solutions**:

1. Verify that you have enabled the service:
   ```nix
   services.mcp-clients.enable = true;
   ```

2. Check that you have at least one enabled server and client:
   ```nix
   services.mcp-clients.servers.local_models.enable = true;
   services.mcp-clients.clients.claude.enable = true;
   ```

3. For home-manager users, verify that the module was properly imported:
   ```nix
   imports = [
     (builtins.fetchTarball "https://github.com/aloshy-ai/nix-mcp-servers/archive/main.tar.gz").homeManagerModules.default
   ];
   ```

### Path Error for FileSystem Server

**Symptom**: You get an error message: "Path must be specified for filesystem server type"

**Solution**: Make sure you've set the `path` attribute for your FileSystem server:

```nix
services.mcp-clients.servers.local_models = {
  enable = true;
  type = "filesystem";
  path = "/path/to/models"; # This is required
  credentials.apiKey = "not-needed";
};
```

## Claude Desktop Issues

### Claude Desktop Doesn't See the Local Models

**Symptom**: Claude Desktop doesn't show your local models even though the configuration file exists.

**Possible Solutions**:

1. Check the configuration file was created correctly:
   ```bash
   # macOS
   cat ~/Library/Application\ Support/Claude/mcp-config.json

   # Linux
   cat ~/.config/claude-desktop/mcp-config.json
   ```

2. Verify the model files exist in the location specified by the `path` parameter

3. Ensure Claude Desktop has been restarted after the configuration was applied

4. Verify the user running Claude Desktop has read permissions for the model files

## Permission Issues

### Cannot Access Model Files

**Symptom**: Claude Desktop shows the FileSystem server but cannot access the model files.

**Solution**: Make sure the user running Claude Desktop has read permissions for the model directory and files:

```bash
# For a single user
chmod 700 /path/to/models
chmod 600 /path/to/models/*

# For shared access
chmod 750 /path/to/models
chmod 640 /path/to/models/*
```

## Getting Help

If you're still experiencing issues after trying these solutions, please:

1. Open an issue on the [GitHub repository](https://github.com/aloshy-ai/nix-mcp-servers/issues)
2. Include your configuration and any error messages
3. Describe the steps you've already taken to troubleshoot the problem
