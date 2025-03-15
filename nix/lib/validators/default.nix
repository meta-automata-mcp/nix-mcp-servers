{lib, ...}:
with lib; rec {
  validateGithubToken = token:
    pkgs.stdenv.mkDerivation {
      name = "validate-github-token";

      # Build dependencies
      buildInputs = [pkgs.curl];

      # Pass the token into the derivation
      TOKEN = token;

      phases = ["buildPhase"];

      # The build phase performs the actual token validation
      buildPhase = ''
        echo "Validating GitHub token..."
        response_code=$(curl -s -o /dev/null -w "%{http_code}" \
          -H "Authorization: token $TOKEN" \
          "https://api.github.com/user")

        if [ "$response_code" = "200" ]; then
          echo "Token is valid" > $out
        else
          echo "Invalid GitHub Token" >&2
          exit 1
        fi
      '';

      # A simple install phase (here it's unnecessary)
      installPhase = "true";
    };
}
