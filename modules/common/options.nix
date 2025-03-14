# modules/common/options.nix
{ lib, ... }:

{
  options.services.mcp-servers = {
    # Overall enable flag
    enable = lib.mkEnableOption "MCP server and client configurations";

    # Server configurations
    servers = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule (import ./server-options.nix { inherit lib; }));
      default = {};
      description = "MCP servers configuration";
    };

    # Client configurations
    clients = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule (import ./client-options.nix { inherit lib; }));
      default = {};
      description = "MCP clients to configure";
    };
  };
}