{
  # Snowfall Lib provides a customized `lib` instance with access to your flake's library as well as the libraries available from your flake's inputs.
  lib,
  # An instance of `pkgs` with your overlays and packages applied is also available.
  pkgs,
  # You also have access to your flake's inputs.
  inputs,
  # Additional metadata is provided by Snowfall Lib.
  namespace, # The namespace used for your flake, defaulting to "internal" if not set.
  system, # The system architecture for this host (eg. `x86_64-linux`).
  target, # The Snowfall Lib target for this system (eg. `x86_64-iso`).
  format, # A normalized name for the system target (eg. `iso`).
  virtual, # A boolean to determine whether this system is a virtual target using nixos-generators.
  systems, # An attribute map of your defined hosts.
  # All other arguments come from the module system.
  config,
  ...
}: let
  cfg = config.${namespace}.clients.cursor;
  rootCfg = config.${namespace};

  # This function builds a server configuration for the given server type
  buildServerConfig = serverType: let
    serverCfg = config.${namespace}.servers.${serverType};
  in
    if serverCfg.enable or false
    then {
      "${serverType}" =
        {
          command = serverCfg.command;
          args = serverCfg.args;
        }
        // (
          if serverCfg ? env
          then {inherit (serverCfg) env;}
          else {}
        );
    }
    else {};

  # Collect all enabled servers for this client
  enabledServers = lib.foldl (
    acc: serverType:
      acc // (buildServerConfig serverType)
  ) {} ["filesystem" "github"];

  # The final JSON configuration
  jsonConfig = builtins.toJSON {
    mcpServers = enabledServers;
  };
in {
  # config.${namespace}.clients.cursor.default

  imports = [
    ./filesystem
    ./github
  ];

  options.${namespace}.clients.cursor = with lib.types; {
    enable = lib.mkOption {
      type = bool;
      description = "Whether to enable the Cursor client";
      default = false;
    };

    configPath = lib.mkOption {
      type = str;
      description = "Path to store the Cursor MCP configuration file";
      default =
        if pkgs.stdenv.isDarwin
        then "${config.home.homeDirectory}/Library/Application Support/cursor/mcp/config.json"
        else "${config.xdg.configHome}/cursor/mcp/config.json";
    };
  };

  config = lib.mkIf (cfg.enable && rootCfg.clients.generateConfigs) {
    home.file.${cfg.configPath} = {
      text = jsonConfig;
      onChange = ''
        echo "Updated Cursor MCP configuration at ${cfg.configPath}"
      '';
    };
  };
}
