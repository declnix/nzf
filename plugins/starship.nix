# Starship - Cross-shell prompt
{ lib, pkgs }:

{
  package = pkgs.starship;
  lazy = false;  # Prompt should load immediately
  
  after = ''
    # Initialize starship prompt
    eval "$(starship init zsh)"
    
    # Custom starship functions
    starship-toggle-time() {
      if [[ -z "$STARSHIP_TIME_ENABLED" ]]; then
        export STARSHIP_TIME_ENABLED=1
        echo "Starship time display enabled"
      else
        unset STARSHIP_TIME_ENABLED
        echo "Starship time display disabled"
      fi
    }
    
    starship-reload() {
      exec zsh
    }
  '';
  
  env = {
    # Starship configuration file location
    STARSHIP_CONFIG = "$HOME/.config/starship.toml";
    # Cache directory
    STARSHIP_CACHE = "$HOME/.cache/starship";
  };
  
  keys = [
    { key = "^X^S"; action = "starship-toggle-time"; desc = "Toggle starship time display"; }
    { key = "^X^R"; action = "starship-reload"; desc = "Reload starship config"; }
  ];
}