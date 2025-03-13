# modules/common/default.nix
# Common module that defines the core options for MCP clients
{lib, ...}: {
  imports = [
    ./options.nix
  ];
}
