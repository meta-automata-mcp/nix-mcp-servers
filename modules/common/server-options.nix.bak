# modules/common/server-options.nix
{ lib }: { name, config, ... }: 

let
  # Base options that all server types support
  baseOptions = {
    command = lib.mkOption {
      type = lib.types.str;
      default = "npx";
      description = "Command to run the MCP server";
    };

    env = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = "Environment variables to set when running the server";
    };
  };

  # Filesystem-specific options
  filesystemOptions = {
    filesystem = {
      args = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "-y" "@modelcontextprotocol/server-filesystem" ];
        description = "Default arguments for the filesystem MCP server";
      };

      extraArgs = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = "Directories to provide access to";
        example = [ "/home/user/Documents" "/home/user/Projects" ];
      };
    };
  };

  # GitHub-specific options (no additional options beyond env variables)
  githubOptions = {};

  # Type-specific option sets
  serverTypeOptions = {
    "filesystem" = filesystemOptions;
    "github" = githubOptions;
  };

in {
  options = baseOptions // 
    (serverTypeOptions.${config.type} or {});

  config = {
    # Automatically set type based on the attrset name, but allow override
    type = lib.mkDefault name;

    # Server type-specific assertions
    assertions = 
      # For filesystem type - validate extraArgs has at least one valid path
      (lib.optional (config.type == "filesystem") {
        assertion = config.filesystem.extraArgs != [];
        message = "You must specify at least one directory in filesystem.extraArgs for the '${name}' filesystem server";
      }) ++
      # For github type - validate GITHUB_PERSONAL_ACCESS_TOKEN is set
      (lib.optional (config.type == "github") {
        assertion = config.env ? "GITHUB_PERSONAL_ACCESS_TOKEN";
        message = "You must set env.GITHUB_PERSONAL_ACCESS_TOKEN for the '${name}' github server";
      });
  };
}