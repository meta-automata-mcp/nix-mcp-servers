# lib/default.nix
{
  lib,
  pkgs ? null,
  inputs ? null,
}: {
  # Platform detection helpers
  platforms = import ./platforms.nix {inherit lib;};

  # MCP server utilities
  servers = import ./servers.nix {inherit lib;};

  # Client configuration generators
  clients = import ./clients.nix {inherit lib;};

  # Utilities for path handling
  paths = import ./paths.nix {inherit lib;};

  # Documentation support
  docs =
    if pkgs != null && inputs != null
    then import ./doc-support.nix {inherit pkgs lib inputs;}
    else {};
}
