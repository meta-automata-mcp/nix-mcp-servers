# packages/mcp-setup-cli.nix
{
  lib,
  stdenv,
  makeWrapper,
  bash,
  jq,
  curl,
}:
stdenv.mkDerivation {
  name = "mcp-setup-cli";

  buildInputs = [makeWrapper bash jq curl];

  src = ./.;

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin

    # Create the mcp-setup script
    cat > $out/bin/mcp-setup << 'EOF'
    #!/usr/bin/env bash
    set -e

    # Functionality to generate/update configurations
    echo "MCP Setup CLI"
    echo "=============="
    echo "This tool configures MCP clients based on your NixOS/Darwin configuration."
    echo ""
    echo "To use, add services.mcp-clients configuration to your NixOS or Home Manager configuration."

    # Example output
    echo "Example configuration:"
    echo ""
    echo "  services.mcp-clients = {"
    echo "    enable = true;"
    echo "    servers.filesystem = {"
    echo "      enable = true;"
    echo "      type = \"filesystem\";"
    echo "      path = \"/path/to/models\";"
    echo "    };"
    echo "    clients.claude_desktop = {"
    echo "      enable = true;"
    echo "      clientType = \"claude_desktop\";"
    echo "    };"
    echo "  };"
    EOF

    chmod +x $out/bin/mcp-setup

    # Wrap the script with necessary dependencies
    wrapProgram $out/bin/mcp-setup \
      --prefix PATH : ${lib.makeBinPath [bash jq curl]}
  '';

  meta = with lib; {
    description = "CLI tool for MCP client configuration management";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
