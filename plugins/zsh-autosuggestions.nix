{ lib, pkgs }:

{
  # Zsh autosuggestions plugin
  package = pkgs.zsh-autosuggestions;
  lazy = true;
  defer = 1;
  
  # Use zsh.plugins format for direct integration
  zshPlugin = {
    name = "zsh-autosuggestions";
    src = pkgs.zsh-autosuggestions;
    file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
  };
  
  after = ''
    # Autosuggestions configuration
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#666666,underline"
    ZSH_AUTOSUGGEST_STRATEGY=(history completion)
    ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
    ZSH_AUTOSUGGEST_USE_ASYNC=1
    
    # Custom accept suggestion keybindings
    bindkey '^[' autosuggest-accept  # Alt to accept suggestion
    bindkey '^I' complete-word       # Tab for completion, not suggestion
  '';
}