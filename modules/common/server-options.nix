# modules/common/server-options.nix
{lib}: {name, ...}: {
  options = {
    enable = lib.mkEnableOption "this MCP server";

    name = lib.mkOption {
      type = lib.types.str;
      default = name;
      description = "User-friendly name for this server";
      example = "Local Claude";
    };

    type = lib.mkOption {
      type = lib.types.enum ["filesystem"];
      default = name;
      description = "Type of MCP server";
      example = "filesystem";
    };

    baseUrl = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Base URL for the API (optional)";
      example = "http://localhost:8000/api";
    };

    path = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "File system path for filesystem server type. This should point to a directory containing model files or a specific model file.";
      example = "/home/user/models/llama3";
    };

    credentials = lib.mkOption {
      type = lib.types.submodule {
        options = {
          apiKey = lib.mkOption {
            type = lib.types.str;
            description = "API key for authentication";
            example = "sk-1234567890";
          };
        };
      };
      description = "Credentials for this MCP server";
    };
  };
}
