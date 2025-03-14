# lib/platforms.nix
{ lib }:

{
  # Determine if a system is Darwin-based
  isDarwin = system: builtins.match ".*darwin" system != null;
  
  # Determine if a system is Linux-based
  isLinux = system: builtins.match ".*linux" system != null;
  
  # Get the base directory for application configurations based on platform
  getConfigBase = system:
    if isDarwin system
    then "~/Library/Application Support"
    else "~/.config";
    
  # Get the cache directory based on platform
  getCacheDir = system:
    if isDarwin system
    then "~/Library/Caches"
    else "~/.cache";
    
  # Validate if a path exists and is accessible
  # This function should be used in activation scripts to validate paths
  validatePath = path: ''
    if [ ! -e "${path}" ]; then
      echo "Warning: Path '${path}' does not exist"
      mkdir -p "${path}" || echo "Could not create directory '${path}'"
    fi
  '';
}