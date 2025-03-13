# modules/nixos/default.nix - NixOS-specific implementation
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.mcp-clients;
in {
  config = lib.mkIf cfg.enable {
    # NixOS specific implementation
    environment.systemPackages = [pkgs.jq pkgs.curl];

    # Use system state directory
    services.mcp-clients.stateDir = lib.mkDefault "/var/lib/mcp-setup";
  };
}
