# modules/home-manager.nix - Home Manager implementation
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.mcp-clients;
in {
  config = lib.mkIf cfg.enable {
    # Home Manager specific implementation
    home.packages = [pkgs.jq pkgs.curl];

    # Use home directory for state
    services.mcp-clients.stateDir = lib.mkDefault "~/.local/state/mcp-setup";
  };
}
