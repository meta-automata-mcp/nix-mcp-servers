# modules/documentation/extract-options.nix
{
  lib,
  system,
  pkgs,
  ...
}: let
  # Evaluate the modules to extract options
  eval = lib.evalModules {
    modules = [
      {
        imports = [
          ../common/options.nix
        ];
        # Required settings
        services.mcp-servers.enable = true;
      }
    ];
    # Required arguments
    specialArgs = {
      modulesPath = builtins.toString ../..;
      pkgs = pkgs;
      lib = lib;
    };
  };

  # Helper function to display type information safely
  safeTypeToString = type:
    if type ? description
    then type.description
    else if builtins.isFunction type.check
    then "function"
    else if builtins.hasAttr "name" type
    then type.name
    else builtins.typeOf type;

  # Helper function to extract option info
  extractOptionInfo = opt: {
    description = opt.description or "No description available";
    type = safeTypeToString (opt.type or {});
    default =
      if opt ? default
      then builtins.toJSON opt.default
      else null;
    example =
      if opt ? example
      then builtins.toJSON opt.example
      else null;
  };

  # Get the services.mcp-servers options
  mcpOptions = eval.options.services.mcp-servers;

  # Extract base options
  baseOptions =
    lib.mapAttrs (name: opt: extractOptionInfo opt)
    (removeAttrs mcpOptions ["servers" "clients"]);

  # Extract server-level options (those directly in servers.<name>, not including type-specific)
  serverBaseOptions =
    if mcpOptions ? servers && mcpOptions.servers ? type && mcpOptions.servers.type ? options
    then
      lib.mapAttrs (name: opt: extractOptionInfo opt)
      (mcpOptions.servers.type.options or {})
    else {};

  # Extract client-level options
  clientOptions =
    if mcpOptions ? clients && mcpOptions.clients ? type && mcpOptions.clients.type ? options
    then
      lib.mapAttrs (name: opt: extractOptionInfo opt)
      (mcpOptions.clients.type.options or {})
    else {};

  # Extract filesystem server specific options
  # This is harder because it's nested. If we can't access it properly, provide empty set for now
  filesystemOptions = {};

  # Bundle the extracted options
  optionsBundle = {
    base = baseOptions;
    servers = serverBaseOptions;
    clients = clientOptions;
    filesystem = filesystemOptions;
  };
in
  optionsBundle
