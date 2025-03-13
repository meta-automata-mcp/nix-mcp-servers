# lib/servers.nix
{ lib }:

{
  # List of supported server types
  supportedTypes = [
    "anthropic"
    "openai"
    "together_ai"
    "groq"
    "mistral"
    "ollama"
  ];
  
  # Default base URLs for known services
  defaultBaseUrls = {
    anthropic = "https://api.anthropic.com";
    openai = "https://api.openai.com";
    together_ai = "https://api.together.xyz";
    groq = "https://api.groq.com";
    mistral = "https://api.mistral.ai";
    ollama = "http://localhost:11434"; # Default local Ollama instance
  };
  
  # Format server configuration for specific client types
  formatForClient = { server, clientType }:
    if clientType == "claude_desktop" then {
      name = "${server.name} API";
      type = server.type;
      apiKey = server.credentials.apiKey;
      baseUrl = server.baseUrl or lib.servers.defaultBaseUrls.${server.type} or null;
    }
    else if clientType == "cursor_ide" then {
      provider = server.type;
      apiKey = server.credentials.apiKey;
      baseUrl = server.baseUrl or lib.servers.defaultBaseUrls.${server.type} or null;
    }
    else if clientType == "vscode_extension" then {
      name = server.name;
      type = server.type;
      apiKey = server.credentials.apiKey;
      baseUrl = server.baseUrl or lib.servers.defaultBaseUrls.${server.type} or null;
    }
    else {
      # Generic format
      name = server.name;
      type = server.type;
      apiKey = server.credentials.apiKey;
      baseUrl = server.baseUrl or lib.servers.defaultBaseUrls.${server.type} or null;
    };
}