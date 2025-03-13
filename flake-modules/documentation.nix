# flake-modules/documentation.nix - Documentation generator for MCP servers options
{
  self,
  lib,
  config,
  flake-parts-lib,
  ...
}: {
  options = {
    # Documentation options can be added here if needed
  };

  config = {
    perSystem = {
      system,
      pkgs,
      ...
    }: {
      # Generate documentation package
      packages.docs = pkgs.writeTextFile {
        name = "mcp-servers-options-docs";
        text =
          builtins.toJSON
          (
            lib.evalModules {
              modules = [
                {imports = [../modules/common/options.nix];}
                {_module.check = false;}
              ];
            }
          )
          .options
          .services
          .mcp-clients;
        destination = "/share/doc/mcp-servers/options.json";
      };

      # Add a script to view the documentation
      apps.view-docs = {
        type = "app";
        program =
          toString
          (pkgs.writeShellScriptBin "view-mcp-options" ''
            ${pkgs.jq}/bin/jq -r . ${self.packages.${system}.docs}/share/doc/mcp-servers/options.json | ${pkgs.less}/bin/less
          '')
          .outPath
          + "/bin/view-mcp-options";
      };

      # Generate comprehensive Markdown documentation
      packages.docs-md = pkgs.writeTextFile {
        name = "mcp-servers-options-docs-md";
        text = ''
          # MCP Servers Module Options

          This document provides a reference for all the available options in the MCP servers modules.

          ## General Options

          | Option | Type | Default | Description |
          |--------|------|---------|-------------|
          | `services.mcp-clients.enable` | boolean | `false` | Whether to enable the MCP clients service |
          | `services.mcp-clients.stateDir` | string | `~/.local/state/mcp-setup` or `/var/lib/mcp-setup` | Directory to store MCP configuration state |

          ## Server Options

          | Option | Type | Default | Description |
          |--------|------|---------|-------------|
          | `services.mcp-clients.servers.<name>.enable` | boolean | `false` | Whether to enable this MCP server |
          | `services.mcp-clients.servers.<name>.name` | string | name attribute | User-friendly name for this server |
          | `services.mcp-clients.servers.<name>.type` | enum | name attribute | Type of MCP server (filesystem) |
          | `services.mcp-clients.servers.<name>.baseUrl` | string or null | `null` | Base URL for the API (optional) |
          | `services.mcp-clients.servers.<name>.path` | string or null | `null` | File system path for filesystem server type |
          | `services.mcp-clients.servers.<name>.credentials.apiKey` | string | | API key for authentication |

          ## Client Options

          | Option | Type | Default | Description |
          |--------|------|---------|-------------|
          | `services.mcp-clients.clients.<name>.enable` | boolean | `false` | Whether to enable this MCP client |
          | `services.mcp-clients.clients.<name>.clientType` | enum | name attribute | Type of MCP client (claude_desktop) |
          | `services.mcp-clients.clients.<name>.configPath` | string | platform-dependent | Path to the client configuration file |
          | `services.mcp-clients.clients.<name>.servers` | list of strings | all enabled servers | List of MCP servers to use with this client |

          ---

          *Note: This documentation is automatically generated from the module options declarations. For the most up-to-date information, you can run `nix run github:aloshy-ai/nix-mcp-servers#view-docs`.*
        '';
        destination = "/share/doc/mcp-servers/options.md";
      };

      # Generate example files
      packages.example-nixos = pkgs.writeTextFile {
        name = "mcp-servers-nixos-example";
        text = ''
          # NixOS Example

          This example demonstrates how to use the MCP servers module with NixOS.

          ## Basic Configuration

          ```nix
          {
            inputs = {
              nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
              mcp-servers.url = "github:aloshy-ai/nix-mcp-servers";
            };

            outputs = { self, nixpkgs, mcp-servers, ... }: {
              nixosConfigurations.hostname = nixpkgs.lib.nixosSystem {
                # Your system architecture
                system = "x86_64-linux";
                modules = [
                  mcp-servers.nixosModules.default
                  {
                    services.mcp-clients = {
                      enable = true;
                      servers.local_models = {
                        enable = true;
                        name = "Local Models";
                        type = "filesystem";
                        path = "/path/to/models";
                        credentials.apiKey = "not-needed";
                      };
                      clients.claude = {
                        enable = true;
                        clientType = "claude_desktop";
                      };
                    };
                  }
                ];
              };
            };
          }
          ```

          ## Alternative Import Method

          You can also import the module directly using:

          ```nix
          {
            imports = [
              (builtins.fetchTarball "https://github.com/aloshy-ai/nix-mcp-servers/archive/main.tar.gz").nixosModules.default
            ];

            services.mcp-clients = {
              enable = true;
              # ... configuration ...
            };
          }
          ```

          ## Advanced Configuration

          For more advanced configuration options, refer to the [module options documentation](../modules/options.md).
        '';
        destination = "/share/doc/mcp-servers/examples/nixos.md";
      };

      packages.example-darwin = pkgs.writeTextFile {
        name = "mcp-servers-darwin-example";
        text = ''
          # Darwin Example

          This example demonstrates how to use the MCP servers module with nix-darwin.

          ## Basic Configuration

          ```nix
          {
            inputs = {
              nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
              darwin.url = "github:lnl7/nix-darwin";
              darwin.inputs.nixpkgs.follows = "nixpkgs";
              mcp-servers.url = "github:aloshy-ai/nix-mcp-servers";
            };

            outputs = { self, nixpkgs, darwin, mcp-servers, ... }: {
              darwinConfigurations.hostname = darwin.lib.darwinSystem {
                # Your system architecture
                system = "aarch64-darwin";
                modules = [
                  mcp-servers.darwinModules.default
                  {
                    services.mcp-clients = {
                      enable = true;
                      servers.local_models = {
                        enable = true;
                        name = "Local Models";
                        type = "filesystem";
                        path = "/Users/username/models";
                        credentials.apiKey = "not-needed";
                      };
                      clients.claude = {
                        enable = true;
                        clientType = "claude_desktop";
                      };
                    };
                  }
                ];
              };
            };
          }
          ```

          ## Alternative Import Method

          You can also import the module directly using:

          ```nix
          {
            imports = [
              (builtins.fetchTarball "https://github.com/aloshy-ai/nix-mcp-servers/archive/main.tar.gz").darwinModules.default
            ];

            services.mcp-clients = {
              enable = true;
              # ... configuration ...
            };
          }
          ```

          ## Advanced Configuration

          For more advanced configuration options, refer to the [module options documentation](../modules/options.md).
        '';
        destination = "/share/doc/mcp-servers/examples/darwin.md";
      };

      packages.example-home-manager = pkgs.writeTextFile {
        name = "mcp-servers-home-manager-example";
        text = ''
          # Home Manager Example

          This example demonstrates how to use the MCP servers module with Home Manager.

          ## Basic Configuration

          ```nix
          {
            inputs = {
              nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
              home-manager.url = "github:nix-community/home-manager";
              mcp-servers.url = "github:aloshy-ai/nix-mcp-servers";
            };

            outputs = { self, nixpkgs, home-manager, mcp-servers, ... }: {
              homeConfigurations.username = home-manager.lib.homeManagerConfiguration {
                pkgs = nixpkgs.legacyPackages.x86_64-linux;
                modules = [
                  mcp-servers.nixosModules.home-manager
                  {
                    services.mcp-clients = {
                      enable = true;
                      servers.local_models = {
                        enable = true;
                        name = "Local Models";
                        type = "filesystem";
                        path = "~/models";
                        credentials.apiKey = "not-needed";
                      };
                      clients.claude = {
                        enable = true;
                        clientType = "claude_desktop";
                      };
                    };
                  }
                ];
              };
            };
          }
          ```

          ## Alternative Import Method

          You can also import the module directly using:

          ```nix
          {
            imports = [
              (builtins.fetchTarball "https://github.com/aloshy-ai/nix-mcp-servers/archive/main.tar.gz").nixosModules.home-manager
            ];

            services.mcp-clients = {
              enable = true;
              # ... configuration ...
            };
          }
          ```

          ## Advanced Configuration

          For more advanced configuration options, refer to the [module options documentation](../modules/options.md).
        '';
        destination = "/share/doc/mcp-servers/examples/home-manager.md";
      };

      packages.filesystem-schema = pkgs.writeTextFile {
        name = "mcp-servers-filesystem-schema";
        text = ''
          {
            "mcpServers": [
              {
                "name": "Local FileSystem API",
                "type": "filesystem",
                "apiKey": "not-needed",
                "baseUrl": null,
                "path": "/path/to/models"
              }
            ]
          }
        '';
        destination = "/share/doc/mcp-servers/schema-examples/filesystem-claude.json";
      };

      packages.filesystem-doc = pkgs.writeTextFile {
        name = "mcp-servers-filesystem-doc";
        text = ''
          # FileSystem Server Type

          The `filesystem` server type allows Claude Desktop to load and use AI models stored locally on your filesystem.

          ## Configuration

          ### Required Parameters

          - `type`: Must be set to `"filesystem"`
          - `path`: Path to either:
            - A directory containing model files
            - A specific model file

          ### Optional Parameters

          - `name`: A user-friendly name for this server
          - `baseUrl`: Not used for filesystem type, can be left as `null`
          - `credentials.apiKey`: Not functionally used but required by schema, can be any string

          ## Example Configuration

          ```nix
          # In your configuration.nix, home.nix, or darwin-configuration.nix:
          services.mcp-clients = {
            enable = true;

            servers.local_models = {
              enable = true;
              name = "Local Models";
              type = "filesystem";
              path = "/Users/username/Documents/AI/models";
              credentials.apiKey = "not-needed";
            };

            clients.claude = {
              enable = true;
              clientType = "claude_desktop";
              servers = [ "local_models" ];
            };
          };
          ```

          ## Compatibility

          Compatible with Claude Desktop client only.

          ## Notes

          - Ensure your model files are in a compatible format for Claude Desktop
          - The client must have read permissions for the specified path
          - For security, avoid placing sensitive files in the models directory
        '';
        destination = "/share/doc/mcp-servers/servers/filesystem.md";
      };

      packages.docs-readme = pkgs.writeTextFile {
        name = "mcp-servers-docs-readme";
        text = ''
          # MCP Server Documentation

          This directory contains documentation for the supported MCP servers and clients.

          ## Servers

          - [FileSystem](./servers/filesystem.md) - Local filesystem-based models

          ## Clients

          - Claude Desktop - Anthropic's Claude desktop application

          ## Schema Examples

          See the [schema-examples](./schema-examples) directory for example JSON configurations.

          ## Troubleshooting

          If you encounter issues, please refer to the [troubleshooting guide](./troubleshooting.md).

          ## Configuration Guide

          For detailed configuration instructions, please refer to the main [README.md](../README.md).
        '';
        destination = "/share/doc/mcp-servers/README.md";
      };

      packages.troubleshooting = pkgs.writeTextFile {
        name = "mcp-servers-troubleshooting";
        text = ''
          # Troubleshooting

          This document provides solutions for common issues you might encounter when using the MCP FileSystem server with Claude Desktop.

          ## Configuration Issues

          ### Configuration File Not Being Created

          **Symptom**: The configuration file is not being created in the expected location after running `nixos-rebuild`, `darwin-rebuild`, or `home-manager switch`.

          **Possible Solutions**:

          1. Verify that you have enabled the service:
             ```nix
             services.mcp-clients.enable = true;
             ```

          2. Check that you have at least one enabled server and client:
             ```nix
             services.mcp-clients.servers.local_models.enable = true;
             services.mcp-clients.clients.claude.enable = true;
             ```

          3. For home-manager users, verify that the module was properly imported:
             ```nix
             imports = [
               (builtins.fetchTarball "https://github.com/aloshy-ai/nix-mcp-servers/archive/main.tar.gz").homeManagerModules.default
             ];
             ```

          ### Path Error for FileSystem Server

          **Symptom**: You get an error message: "Path must be specified for filesystem server type"

          **Solution**: Make sure you've set the `path` attribute for your FileSystem server:

          ```nix
          services.mcp-clients.servers.local_models = {
            enable = true;
            type = "filesystem";
            path = "/path/to/models"; # This is required
            credentials.apiKey = "not-needed";
          };
          ```

          ## Claude Desktop Issues

          ### Claude Desktop Doesn't See the Local Models

          **Symptom**: Claude Desktop doesn't show your local models even though the configuration file exists.

          **Possible Solutions**:

          1. Check the configuration file was created correctly:
             ```bash
             # macOS
             cat ~/Library/Application\ Support/Claude/mcp-config.json

             # Linux
             cat ~/.config/claude-desktop/mcp-config.json
             ```

          2. Verify the model files exist in the location specified by the `path` parameter

          3. Ensure Claude Desktop has been restarted after the configuration was applied

          4. Verify the user running Claude Desktop has read permissions for the model files

          ## Permission Issues

          ### Cannot Access Model Files

          **Symptom**: Claude Desktop shows the FileSystem server but cannot access the model files.

          **Solution**: Make sure the user running Claude Desktop has read permissions for the model directory and files:

          ```bash
          # For a single user
          chmod 700 /path/to/models
          chmod 600 /path/to/models/*

          # For shared access
          chmod 750 /path/to/models
          chmod 640 /path/to/models/*
          ```

          ## Getting Help

          If you're still experiencing issues after trying these solutions, please:

          1. Open an issue on the [GitHub repository](https://github.com/aloshy-ai/nix-mcp-servers/issues)
          2. Include your configuration and any error messages
          3. Describe the steps you've already taken to troubleshoot the problem
        '';
        destination = "/share/doc/mcp-servers/troubleshooting.md";
      };

      # Combined documentation package
      packages.full-docs = pkgs.symlinkJoin {
        name = "mcp-servers-full-docs";
        paths = [
          self.packages.${system}.docs
          self.packages.${system}.docs-md
          self.packages.${system}.example-nixos
          self.packages.${system}.example-darwin
          self.packages.${system}.example-home-manager
          self.packages.${system}.filesystem-schema
          self.packages.${system}.filesystem-doc
          self.packages.${system}.docs-readme
          self.packages.${system}.troubleshooting
        ];
      };

      # Add a script to copy the documentation to the docs directory
      apps.update-docs = {
        type = "app";
        program =
          toString
          (pkgs.writeShellScriptBin "update-mcp-docs" ''
            cp -r ${self.packages.${system}.full-docs}/share/doc/mcp-servers/* ${toString ../docs}/
            echo "Documentation updated in ${toString ../docs}/"
          '')
          .outPath
          + "/bin/update-mcp-docs";
      };
    };
  };
}
