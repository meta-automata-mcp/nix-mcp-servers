# modules/home-manager/default.nix - Home Manager implementation
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
    # Home Manager specific implementation
    home.packages = with pkgs;
      [
        jq
        curl
      ]
      ++ lib.optionals hasNpxServer [
        nodejs
      ];

    # Use home directory for state
    services.mcp-clients.stateDir = lib.mkDefault "~/.local/state/mcp-servers";
  };
}
