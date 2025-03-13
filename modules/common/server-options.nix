# modules/common/server-options.nix
{lib}: {name, ...}: {
  options = {
    enable = lib.mkEnableOption "this MCP server configuration";

    name = lib.mkOption {
      type = lib.types.str;
      default = name;
      description = ''
        User-friendly name for this server. This will be displayed in client
        interfaces when connecting to the server.
      '';
      example = "Local Claude Models";
    };

    type = lib.mkOption {
      type = lib.types.enum ["filesystem"];
      default = name;
      description = ''
        Type of MCP server. Currently supports:
        - filesystem: Local filesystem-based models
      '';
      example = "filesystem";
    };

    baseUrl = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Base URL for the API (optional). For filesystem type, this is not used
        and can be left as null.
      '';
      example = "http://localhost:8000/api";
    };

    path = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        File system path for filesystem server type. This should point to a
        directory containing model files or a specific model file. Required
        when using the filesystem server type.
      '';
      example = "/home/user/models/llama3";
    };

    credentials = lib.mkOption {
      type = lib.types.submodule {
        options = {
          apiKey = lib.mkOption {
            type = lib.types.str;
            description = ''
              API key for authentication. For filesystem type, this is required
              by the schema but not functionally used - any string can be provided.
            '';
            example = "sk-1234567890";
          };
        };
      };
      description = "Authentication credentials for this MCP server";
    };
  };
}
