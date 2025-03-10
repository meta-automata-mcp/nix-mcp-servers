{
  description = "Cross-platform MCP Server for AI-enabled tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils-plus.url = "github:gytis-ivaskevicius/flake-utils-plus";
  };

  outputs = { self, nixpkgs, flake-utils-plus, ... }@inputs:
    let
      # Define server.js content directly in the flake
      serverContent = ''
        const express = require('express');
        const cors = require('cors');
        const Anthropic = require('@anthropic-ai/sdk');
        require('dotenv').config();

        // Initialize Express app
        const app = express();
        const port = process.env.PORT || 6969;

        // Configure CORS
        const allowedOrigins = (process.env.ALLOWED_ORIGINS || 'http://localhost:8000,https://app.cursor.sh').split(',');
        app.use(cors({
          origin: function(origin, callback) {
            if (!origin || allowedOrigins.indexOf(origin) !== -1) {
              callback(null, true);
            } else {
              callback(new Error('Not allowed by CORS'));
            }
          }
        }));

        // Configure middleware
        app.use(express.json());

        // Initialize AI clients
        const anthropic = new Anthropic({
          apiKey: process.env.ANTHROPIC_API_KEY,
        });

        // MCP protocol endpoint
        app.post('/v1/generate', async (req, res) => {
          try {
            const { model, messages, max_tokens } = req.body;
            
            // Handle different model providers
            if (model.includes('claude')) {
              const response = await anthropic.messages.create({
                model: model,
                max_tokens: max_tokens || 4000,
                messages: messages
              });
              
              return res.json({
                model: model,
                choices: [{
                  message: {
                    content: response.content[0].text,
                    role: 'assistant'
                  }
                }]
              });
            } 
            // Add placeholder for other model providers
            else {
              return res.status(400).json({ error: 'Unsupported model' });
            }
          } catch (error) {
            console.error('Error generating response:', error);
            res.status(500).json({ error: error.message });
          }
        });

        // Health check endpoint
        app.get('/health', (req, res) => {
          res.json({ status: 'ok' });
        });

        // Start the server
        app.listen(port, () => {
          console.log('MCP server listening at http://localhost:' + port);
          console.log('Allowed origins: ' + allowedOrigins.join(', '));
        });
      '';

      # Define models.js content
      modelsContent = ''
        // Available models configuration
        const availableModels = [
          {
            id: 'claude-3-7-sonnet-20250219',
            provider: 'anthropic',
            name: 'Claude 3.7 Sonnet',
            contextWindow: 200000,
            capabilities: {
              coding: true,
              reasoning: true,
              insertion: true
            }
          },
          {
            id: 'claude-3-opus-20240229',
            provider: 'anthropic',
            name: 'Claude 3 Opus',
            contextWindow: 200000,
            capabilities: {
              coding: true,
              reasoning: true,
              insertion: true
            }
          }
        ];

        module.exports = availableModels;
      '';

      # Define package.json content
      packageJsonContent = ''
        {
          "name": "nix-mcp-server",
          "version": "1.0.0",
          "description": "Generic MCP server for AI-enabled tools",
          "main": "server.js",
          "scripts": {
            "start": "node server.js"
          },
          "keywords": [
            "mcp",
            "ai",
            "claude",
            "nix",
            "llm"
          ],
          "dependencies": {
            "@anthropic-ai/sdk": "^0.17.1",
            "cors": "^2.8.5",
            "dotenv": "^16.4.1",
            "express": "^4.18.2"
          }
        }
      '';
    in
    flake-utils-plus.lib.mkFlake {
      inherit self inputs;

      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      outputsBuilder = channels: let
        pkgs = channels.nixpkgs;
      in {
        # Default package for all platforms
        packages.default = pkgs.stdenv.mkDerivation {
          name = "nix-mcp-server";
          version = "1.0.0";
          
          # We don't need a src since we're creating the files ourselves
          dontUnpack = true;
          
          nativeBuildInputs = [ pkgs.makeWrapper ];
          buildInputs = [ pkgs.nodejs_20 ];
          
          installPhase = ''
            mkdir -p $out/lib $out/bin
            
            # Create source files from the content defined in the flake
            cat > $out/lib/server.js << 'EOF'
            ${serverContent}
            EOF
            
            cat > $out/lib/models.js << 'EOF'
            ${modelsContent}
            EOF
            
            cat > $out/lib/package.json << 'EOF'
            ${packageJsonContent}
            EOF
            
            # Create the main wrapper script
            makeWrapper ${pkgs.nodejs_20}/bin/node $out/bin/mcp-server \
              --add-flags "$out/lib/server.js" \
              --set NODE_PATH "$out/lib/node_modules"
            
            # Install dependencies
            mkdir -p $out/lib/node_modules
            cd $out/lib
            export HOME=$TMPDIR
            ${pkgs.nodejs_20}/bin/npm install --production --no-audit --no-fund
          '';
        };

        # Development shell
        devShell = pkgs.mkShell {
          buildInputs = [
            pkgs.nodejs_20
            pkgs.nodePackages.npm
            pkgs.nodePackages.nodemon
          ];
          
          shellHook = ''
            export PATH="$PWD/node_modules/.bin:$PATH"
            export NODE_ENV="development"
            
            # Create sample .env file if it doesn't exist
            if [ ! -f .env ]; then
              echo "Creating sample .env file..."
              cat > .env << EOL
ANTHROPIC_API_KEY=your_anthropic_api_key_here
OPENAI_API_KEY=your_openai_api_key_here
PORT=6969
ALLOWED_ORIGINS=http://localhost:8000,https://app.cursor.sh
EOL
            fi
            
            echo "MCP Server development environment ready!"
            echo "Run 'npm start' to start the server"
          '';
        };
      };

      # Default overlay
      overlays.default = final: prev: {
        nix-mcp-server = self.packages.${final.system}.default;
      };

      # NixOS module
      nixosModules.default = { config, lib, pkgs, ... }:
        let
          cfg = config.services.mcp-server;
          
          # Generate environment variables
          environmentVariables = {
            PORT = toString cfg.port;
            ALLOWED_ORIGINS = cfg.allowedOrigins;
            NODE_ENV = "production";
          } // lib.optionalAttrs (cfg.anthropicApiKey != null) {
            ANTHROPIC_API_KEY = cfg.anthropicApiKey;
          } // lib.optionalAttrs (cfg.openaiApiKey != null) {
            OPENAI_API_KEY = cfg.openaiApiKey;
          };
        in {
          options.services.mcp-server = with lib; {
            enable = mkEnableOption "MCP server for AI-enabled tools";
            
            package = mkOption {
              type = types.package;
              default = self.packages.${pkgs.system}.default;
              description = "The MCP server package to use";
            };
            
            port = mkOption {
              type = types.port;
              default = 6969;
              description = "Port on which the MCP server will listen";
            };
            
            allowedOrigins = mkOption {
              type = types.str;
              default = "http://localhost:8000,https://app.cursor.sh";
              description = "Comma-separated list of allowed CORS origins";
            };
            
            anthropicApiKey = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Anthropic API key for Claude models";
            };
            
            openaiApiKey = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "OpenAI API key";
            };
            
            dataDir = mkOption {
              type = types.path;
              default = "/var/lib/mcp-server";
              description = "Directory to store MCP server data";
            };
            
            user = mkOption {
              type = types.str;
              default = "mcp-server";
              description = "User account under which the MCP server runs";
            };
            
            group = mkOption {
              type = types.str;
              default = "mcp-server";
              description = "Group under which the MCP server runs";
            };
          };
          
          config = lib.mkIf cfg.enable {
            users.users.${cfg.user} = {
              isSystemUser = true;
              group = cfg.group;
              description = "MCP server user";
              home = cfg.dataDir;
              createHome = true;
            };
            
            users.groups.${cfg.group} = {};
            
            systemd.services.mcp-server = {
              description = "MCP Server for AI-enabled tools";
              wantedBy = [ "multi-user.target" ];
              after = [ "network.target" ];
              
              serviceConfig = {
                User = cfg.user;
                Group = cfg.group;
                ExecStart = "${cfg.package}/bin/mcp-server";
                Restart = "on-failure";
                WorkingDirectory = cfg.dataDir;
                
                # Standard logging to journald
                StandardOutput = "journal";
                StandardError = "journal";
                
                # Hardening
                NoNewPrivileges = true;
                ProtectSystem = "strict";
                ProtectHome = true;
                PrivateTmp = true;
              };
              
              environment = environmentVariables;
            };
          };
        };

      # Darwin module
      darwinModules.default = { config, lib, pkgs, ... }:
        let
          cfg = config.services.mcp-server;
          
          # Generate environment variables
          environmentVariables = {
            PORT = toString cfg.port;
            ALLOWED_ORIGINS = cfg.allowedOrigins;
            NODE_ENV = "production";
          } // lib.optionalAttrs (cfg.anthropicApiKey != null) {
            ANTHROPIC_API_KEY = cfg.anthropicApiKey;
          } // lib.optionalAttrs (cfg.openaiApiKey != null) {
            OPENAI_API_KEY = cfg.openaiApiKey;
          };
        in {
          options.services.mcp-server = with lib; {
            enable = mkEnableOption "MCP server for AI-enabled tools";
            
            package = mkOption {
              type = types.package;
              default = self.packages.${pkgs.system}.default;
              description = "The MCP server package to use";
            };
            
            port = mkOption {
              type = types.port;
              default = 6969;
              description = "Port on which the MCP server will listen";
            };
            
            allowedOrigins = mkOption {
              type = types.str;
              default = "http://localhost:8000,https://app.cursor.sh";
              description = "Comma-separated list of allowed CORS origins";
            };
            
            anthropicApiKey = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Anthropic API key for Claude models";
            };
            
            openaiApiKey = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "OpenAI API key";
            };
            
            dataDir = mkOption {
              type = types.path;
              default = "/var/lib/mcp-server";
              description = "Directory to store MCP server data";
            };
            
            stdoutPath = mkOption {
              type = types.path;
              default = "/Library/Logs/mcp-server.log";
              description = "Path to stdout log file";
            };
            
            stderrPath = mkOption {
              type = types.path;
              default = "/Library/Logs/mcp-server.error.log";
              description = "Path to stderr log file";
            };
          };
          
          config = lib.mkIf cfg.enable {
            # Create the service
            launchd.daemons.mcp-server = {
              serviceConfig = {
                Label = "com.user.mcp-server";
                ProgramArguments = [
                  "${cfg.package}/bin/mcp-server"
                ];
                RunAtLoad = true;
                KeepAlive = true;
                WorkingDirectory = cfg.dataDir;
                StandardOutPath = cfg.stdoutPath;
                StandardErrorPath = cfg.stderrPath;
                EnvironmentVariables = environmentVariables;
              };
            };
            
            # Create necessary directories
            system.activationScripts.preActivation.text = ''
              mkdir -p ${cfg.dataDir}
              mkdir -p ${lib.strings.dirOf cfg.stdoutPath}
              mkdir -p ${lib.strings.dirOf cfg.stderrPath}
              touch ${cfg.stdoutPath}
              touch ${cfg.stderrPath}
            '';
          };
        };
    };
}