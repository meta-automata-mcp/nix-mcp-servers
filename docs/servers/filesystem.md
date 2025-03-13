# FileSystem Server Type

The `filesystem` server type allows Claude Desktop to load and use AI models stored locally on your filesystem.

## Configuration

### Required Parameters

- `type`: Must be set to `"filesystem"`
- `path`: Path to either:
  - A directory containing model files
  - A specific model file

### Optional Parameters

- `name`: A user-friendly name for this server
- `baseUrl`: Not used for filesystem type, can be left as `null`
- `credentials.apiKey`: Not functionally used but required by schema, can be any string

## Example Configuration

```nix
# In your configuration.nix, home.nix, or darwin-configuration.nix:
services.mcp-clients = {
  enable = true;
  
  servers.local_models = {
    enable = true;
    name = "Local Models";
    type = "filesystem";
    path = "/Users/username/Documents/AI/models";
    credentials.apiKey = "not-needed";
  };
  
  clients.claude = {
    enable = true;
    clientType = "claude_desktop";
    servers = [ "local_models" ];
  };
};
```

## Compatibility

Compatible with Claude Desktop client only.

## Notes

- Ensure your model files are in a compatible format for Claude Desktop
- The client must have read permissions for the specified path
- For security, avoid placing sensitive files in the models directory 