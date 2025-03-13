# modules/common/options.nix - Contains shared module options
{lib, ...}: {
  options.services.mcp-clients = {
    enable = lib.mkEnableOption "MCP client configurations";

    stateDir = lib.mkOption {
      type = lib.types.str;
      default = "~/.local/state/mcp-setup";
      description = "Directory to store MCP configuration state";
      example = "~/.local/state/mcp-custom";
    };

    servers = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule (import ./server-options.nix {inherit lib;}));
      default = {};
      description = "MCP servers configuration";
      example = lib.literalExpression ''
        {
          filesystem = {
            enable = true;
            name = "Local FileSystem";
            type = "filesystem";
            path = "/path/to/models";
            credentials.apiKey = "not-needed";
          };
        }
      '';
    };

    clients = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule (import ./client-options.nix {inherit lib;}));
      default = {};
      description = "MCP clients to configure";
      example = lib.literalExpression ''
        {
          claude_desktop = {
            enable = true;
            clientType = "claude_desktop";
          };
        }
      '';
    };
  };
}
