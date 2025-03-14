# In modules/common/implementation.nix
{ config, lib, pkgs, ... }:

let
  cfg = config.services.mcp-servers;
  inherit (lib) mkIf filterAttrs mapAttrs concatMapStringsSep;
  
  # Import utility functions
  clientsLib = import ../../lib/clients.nix { inherit lib; };
  serversLib = import ../../lib/servers.nix { inherit lib; };
  platformsLib = import ../../lib/platforms.nix { inherit lib; };
  
  # Generate JSON configuration for a client
  generateClientConfig = clientName: clientCfg:
    let
      # Get only the servers specified by this client
      requestedServers = clientCfg.servers;
      
      # Format each server for this client
      formattedServers = mapAttrs 
        (name: server: serversLib.formatForClient { 
          inherit server; 
          clientType = clientCfg.clientType;
          serverName = name;
        })
        (filterAttrs (name: _: builtins.elem name requestedServers) cfg.servers);
        
      # Generate final client config structure
      clientConfig = clientsLib.generateConfig {
        clientType = clientCfg.clientType;
        servers = formattedServers;
      };
      
      # Determine config path
      configPath = if clientCfg.configPath != "" 
        then clientCfg.configPath
        else clientsLib.defaultConfigPath clientCfg.clientType config.system;
        
      # Convert to JSON string
      configJson = builtins.toJSON clientConfig;
    in {
      inherit configPath configJson;
    };
    
  # Generate all client configs
  clientConfigs = mapAttrs generateClientConfig
    (filterAttrs (_: client: client.enable) cfg.clients);
    
  # Generate activation script content for Home Manager
  activationScript = concatMapStringsSep "\n"
    (client: ''
      mkdir -p "$(dirname "${client.configPath}")"
      echo '${client.configJson}' > "${client.configPath}"
      chmod 600 "${client.configPath}"
    '')
    (builtins.attrValues clientConfigs);
    
  # For filesystem servers, validate the paths
  validatePathsScript = concatMapStringsSep "\n"
    (server: 
      if server.type == "filesystem" then
        concatMapStringsSep "\n" 
          (path: platformsLib.validatePath path)
          server.filesystem.extraArgs
      else ""
    )
    (builtins.attrValues (filterAttrs (_: server: server.type == "filesystem") cfg.servers));
    
in {
  config = mkIf cfg.enable {
    # Add Home Manager activation script to write the configs
    home.activation.writeMcpConfigs = lib.hm.dag.entryAfter ["writeBoundary"] ''
      # Validate filesystem paths
      ${validatePathsScript}
      
      # Write client configurations
      ${activationScript}
    '';
  };
}