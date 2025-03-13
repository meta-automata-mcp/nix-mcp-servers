// This rule configures Cursor to use the specified MCP servers
// Place in `.cursor/rules/mcp.ts`

// Description: Configure Cursor to use specific MCP servers for AI assistance
// Apply to: All files in the project
// Pattern: **/*

/**
 * This rule configures Cursor to connect to specified MCP servers.
 * It will be applied to all files in the project.
 * 
 * When using the nix-mcp-servers flake, a configuration file will be generated
 * at ~/.cursor/mcp-config.json with the credentials of the MCP servers you've
 * specified in your Nix configuration.
 */

// This rule configures Cursor to use the MCP servers specified in the mcp-config.json file
// The nix-mcp-servers flake will automatically generate this file for you

export default {
  // Enable MCP functionality
  mcp: {
    enabled: true,
    
    // Configuration options for MCP
    config: {
      // The rule will instruct Cursor to prefer using specified MCP servers when available
      preferMCP: true,
      
      // Load the MCP configuration from the file created by nix-mcp-servers
      configPath: "~/.cursor/mcp-config.json",
      
      // Optional: You can also specify fallback servers directly in the rule
      // This is useful if you want to override or supplement the Nix-generated config
      fallbackServers: [
        // Example fallback server (uncomment and modify as needed)
        /*
        {
          name: "Local Ollama",
          type: "ollama",
          baseUrl: "http://localhost:11434"
        }
        */
      ]
    }
  }
};
