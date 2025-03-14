# modules/common/client-options.nix
{ lib }: { name, ... }: {
  options = {
    enable = lib.mkEnableOption "this MCP client configuration";

    clientType = lib.mkOption {
      type = lib.types.enum ["claudeDesktop" "cursor"];
      default = 
        if name == "claude" then "claudeDesktop"
        else if name == "cursor" then "cursor"
        else "claudeDesktop";
      description = "Type of MCP client to configure";
    };

    configPath = lib.mkOption {
      type = lib.types.str;
      description = "Path to the client configuration file. If not specified, a default path will be used.";
      default = "";
    };

    servers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "List of MCP server names to enable for this client";
      example = ["filesystem" "github"];
    };
  };
}