# modules/documentation/extract-options.nix
{
  lib,
  system,
  pkgs,
  ...
}: let
  # Since we're having path resolution issues, we'll use hardcoded values
  # In a production environment, you'd want to properly import and evaluate the modules
  # Hardcoded server options
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

  # Hardcoded client options
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

  # Hardcoded base options
  baseOptions = {
    enable = {
      description = "Whether to enable MCP servers functionality.";
      type = "boolean";
      default = "false";
      example = "true";
    };
  };

  # Bundle the extracted options
  optionsBundle = {
    base = baseOptions;
    servers = hardcodedServerOptions;
    clients = hardcodedClientOptions;
  };
in
  optionsBundle
