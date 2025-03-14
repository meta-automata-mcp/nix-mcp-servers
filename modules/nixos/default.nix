# modules/nixos/default.nix - NixOS-specific implementation
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.mcp-clients;

  # Check if any server is using npx command
  hasNpxServer =
    lib.any (server: server.enable && server.command == "npx")
    (lib.attrValues cfg.servers);
in {
  config = lib.mkIf cfg.enable {
    # NixOS specific implementation
    environment.systemPackages = with pkgs;
      [
        jq
        curl
      ]
      ++ lib.optionals hasNpxServer [
        nodejs
      ];

    # Use system state directory
    services.mcp-clients.stateDir = lib.mkDefault "/var/lib/mcp-servers";
  };
}
