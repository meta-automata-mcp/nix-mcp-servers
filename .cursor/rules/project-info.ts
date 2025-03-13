// Place in `.cursor/rules/project-info.ts`

// Description: Provides context about the project and coding standards
// Apply to: All files in the project
// Pattern: **/*

/**
 * This rule provides information about the project to Cursor's AI.
 * It helps the AI understand your project structure, coding standards,
 * and how the nix-mcp-servers flake is used in your environment.
 */

export default {
  // Basic project information
  description: `
    This project is configured to use MCP (Model Control Protocol) servers via the nix-mcp-servers flake.
    Configuration files for various MCP clients (including Cursor) are generated automatically
    through the Nix configuration system.
    
    When working with this codebase:
    1. Any changes to MCP server configurations should be made through the Nix configuration
    2. The generated config for Cursor will be at ~/.cursor/mcp-config.json
    3. This project uses the following development standards:
       - [Your coding standards here]
       - [Your testing approach here]
       - [Your documentation requirements here]
  `,
  
  // Configure the AI assistant to be aware of the MCP setup
  assistant: {
    // Include context about MCP integration
    context: `
      This project uses a Nix flake (nix-mcp-servers) to manage MCP server configurations.
      The flake generates configuration files for Cursor IDE and other MCP clients.
      When making suggestions about API interactions or AI features, be aware that
      the project can use various MCP-compatible AI providers including Anthropic (Claude),
      OpenAI, Together.ai, Groq, Mistral, and Ollama.
    `,
    
    // Configure assistant behavior
    config: {
      // Add specific configuration for the AI assistant
      // These are examples - adjust based on your project needs
      tone: "professional",
      style: "concise",
      expertiseLevel: "advanced"
    }
  },
  
  // Optional: Add additional context files
  context: {
    files: [
      // Example: Include your project README as context for the AI
      // "@file/README.md",
      
      // Example: Include documentation on MCP usage
      // "@file/docs/mcp-usage.md"
    ]
  }
};
