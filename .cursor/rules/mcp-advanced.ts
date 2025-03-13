// Place in `.cursor/rules/mcp-advanced.ts`

// Description: Configure Cursor to use specific MCP servers for different file types
// Apply to: All files in the project
// Pattern: **/*

/**
 * This advanced rule configures Cursor to connect to different MCP servers
 * based on file types and needs. For example, you might want to use:
 * - Anthropic's Claude for natural language and documentation
 * - OpenAI for code completion
 * - Mistral for specific languages
 * - Ollama for local processing of less sensitive files
 */

import fs from 'fs';
import path from 'path';

// Try to load the MCP configuration created by nix-mcp-servers
const loadMcpConfig = () => {
  try {
    const homedir = process.env.HOME || process.env.USERPROFILE;
    const configPath = path.join(homedir, '.cursor', 'mcp-config.json');
    if (fs.existsSync(configPath)) {
      return JSON.parse(fs.readFileSync(configPath, 'utf8'));
    }
  } catch (error) {
    console.error('Error loading MCP config:', error);
  }
  return { mcpConfig: { enabled: true, servers: [] } };
};

const mcpConfig = loadMcpConfig();
const servers = mcpConfig.mcpConfig?.servers || [];

// Function to filter servers by type
const getServersByType = (type) => {
  return servers.filter(server => server.provider === type);
};

export default {
  // The base rule for all files enables MCP with default settings
  mcp: {
    enabled: true,
    
    config: {
      preferMCP: true,
      servers
    }
  },
  
  // File-specific rules can be added here
  rules: [
    // Example: Use Anthropic for documentation files
    {
      description: "Use Anthropic for documentation",
      pattern: "**/*.{md,mdx,txt}",
      mcp: {
        enabled: true,
        config: {
          preferMCP: true,
          servers: getServersByType('anthropic')
        }
      }
    },
    
    // Example: Use OpenAI's models for JavaScript/TypeScript
    {
      description: "Use OpenAI for JavaScript/TypeScript",
      pattern: "**/*.{js,jsx,ts,tsx}",
      mcp: {
        enabled: true,
        config: {
          preferMCP: true,
          servers: getServersByType('openai')
        }
      }
    },
    
    // Example: Use Mistral for Python files
    {
      description: "Use Mistral for Python",
      pattern: "**/*.py",
      mcp: {
        enabled: true,
        config: {
          preferMCP: true,
          servers: getServersByType('mistral')
        }
      }
    },
    
    // Example: Use local Ollama for config files or tests
    {
      description: "Use Ollama for configuration and tests",
      pattern: "**/{*.json,*.yaml,*.yml,*_test.go,*.spec.ts}",
      mcp: {
        enabled: true,
        config: {
          preferMCP: true,
          servers: getServersByType('ollama')
        }
      }
    }
  ]
};
