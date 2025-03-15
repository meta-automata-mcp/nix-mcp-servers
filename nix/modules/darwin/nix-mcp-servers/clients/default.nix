{
  # Snowfall Lib provides a customized `lib` instance with access to your flake's library
  # as well as the libraries available from your flake's inputs.
  lib,
  # An instance of `pkgs` with your overlays and packages applied is also available.
  pkgs,
  # You also have access to your flake's inputs.
  inputs,
  # Additional metadata is provided by Snowfall Lib.
  # The system architecture for this host (eg. `x86_64-linux`).
  system,
  # The Snowfall Lib target for this system (eg. `x86_64-iso`).
  target,
  # A normalized name for the system target (eg. `iso`).
  format,
  # A boolean to determine whether this system is a virtual target using nixos-generators.
  virtual,
  # An attribute map of your defined hosts.
  systems,
  # All other arguments come from the module system.
  config,
  ...
}: let
  namespace = "nix-mcp-servers";
  cfg = config.${namespace}.clients;
in {
  # config.${namespace}.clients.default

  imports = [
    ./cursor
    ./claude
  ];

  options.${namespace}.clients = with lib.types; {
    generateConfigs = lib.mkOption {
      type = bool;
      description = "Whether to generate MCP configuration files";
      default = true;
    };
  };
}
