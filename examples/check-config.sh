#!/bin/bash

# Check Claude configuration
CLAUDE_CONFIG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
if [ -f "$CLAUDE_CONFIG" ]; then
  echo "✅ Claude config exists at: $CLAUDE_CONFIG"
  echo "--- Claude Config Content ---"
  cat "$CLAUDE_CONFIG"
  echo "----------------------------"
else
  echo "❌ Claude config does not exist at: $CLAUDE_CONFIG"
fi

# Check Cursor configuration
CURSOR_CONFIG="$HOME/.cursor/mcp.json"
if [ -f "$CURSOR_CONFIG" ]; then
  echo "✅ Cursor config exists at: $CURSOR_CONFIG"
  echo "--- Cursor Config Content ---"
  cat "$CURSOR_CONFIG"
  echo "----------------------------"
else
  echo "❌ Cursor config does not exist at: $CURSOR_CONFIG"
fi

# Check if servers are enabled in your configuration
echo ""
echo "To enable the servers and clients, add these to your home configuration:"
echo ""
echo "# Enable Claude with filesystem access"
echo "ai.aloshy.clients.claude.enable = true;"
echo "ai.aloshy.clients.claude.filesystem.enable = true;"
echo "ai.aloshy.clients.claude.filesystem.paths = [ \"/Users/$(whoami)/path/to/share\" ];"
echo ""
echo "# Enable Cursor with filesystem access"
echo "ai.aloshy.clients.cursor.enable = true;"
echo "ai.aloshy.clients.cursor.filesystem.enable = true;"
echo "ai.aloshy.clients.cursor.filesystem.paths = [ \"/Users/$(whoami)/path/to/share\" ];"
echo ""
echo "Now check if the directories exist:"
echo ""
echo "Claude config directory:"
echo "ls -la \"$HOME/Library/Application Support/Claude/\""
echo ""
echo "Cursor config directory:"
echo "ls -la \"$HOME/.cursor/\"" 