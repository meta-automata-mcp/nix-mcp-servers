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

  # Hardcoded server options as a fallback
  hardcodedServerOptions = {
    enable = {
      description = "Enable or disable this MCP server configuration.";
      type = "boolean";
      default = "false";
      example = "true";
    };
    command = {
      description = "Command to run the MCP server.";
      type = "string";
      default = "\"npx\"";
      example = "\"/path/to/custom/command\"";
    };
    type = {
      description = "Type of MCP server.";
      type = "string";
      default = null;
      example = "\"filesystem\" or \"github\"";
    };
    env = {
      description = "Environment variables to set when running the server.";
      type = "attribute set of strings";
      default = "{}";
      example = "{ GITHUB_PERSONAL_ACCESS_TOKEN = \"ghp_abcdef123456\"; }";
    };
    "filesystem.args" = {
      description = "Default arguments for the filesystem MCP server.";
      type = "list of strings";
      default = "[\"-y\", \"@modelcontextprotocol/server-filesystem\"]";
      example = null;
    };
    "filesystem.extraArgs" = {
      description = "Directories to provide access to.";
      type = "list of strings";
      default = null;
      example = "[\"/home/user/Documents\", \"/home/user/Projects\"]";
    };
  };

  # Hardcoded client options as a fallback
  hardcodedClientOptions = {
    enable = {
      description = "Whether to enable this MCP client configuration.";
      type = "boolean";
      default = "false";
      example = "true";
    };
    clientType = {
      description = "Type of MCP client to configure.";
      type = "string, one of \"claudeDesktop\", \"cursor\"";
      default = "Depends on the client name";
      example = "\"claudeDesktop\"";
    };
    configPath = {
      description = "Path to the client configuration file. If not specified, a default path will be used.";
      type = "string";
      default = "\"\"";
      example = "\"~/Library/Application Support/Claude/claude_desktop_config.json\"";
    };
    servers = {
      description = "List of MCP server names to enable for this client.";
      type = "list of strings";
      default = "[]";
      example = "[\"filesystem\", \"github\"]";
    };
  };

  # Get the services.mcp-servers options
  mcpOptions = eval.options.services.mcp-servers;

  # Extract base options
  baseOptions =
    lib.mapAttrs (name: opt: extractOptionInfo opt)
    (removeAttrs mcpOptions ["servers" "clients"]);

  # Try to extract server options, fall back to hardcoded if extraction fails
  serverBaseOptions =
    if
      builtins.hasAttr "servers" mcpOptions
      && builtins.hasAttr "type" mcpOptions.servers
      && builtins.hasAttr "options" mcpOptions.servers.type
    then
      lib.mapAttrs (name: opt: extractOptionInfo opt)
      (mcpOptions.servers.type.options or {})
    else hardcodedServerOptions;

  # Try to extract client options, fall back to hardcoded if extraction fails
  clientOptions =
    if
      builtins.hasAttr "clients" mcpOptions
      && builtins.hasAttr "type" mcpOptions.clients
      && builtins.hasAttr "options" mcpOptions.clients.type
    then
      lib.mapAttrs (name: opt: extractOptionInfo opt)
      (mcpOptions.clients.type.options or {})
    else hardcodedClientOptions;

  # Bundle the extracted options
  optionsBundle = {
    base = baseOptions;
    servers = serverBaseOptions;
    clients = clientOptions;
  };
in
  optionsBundle
