{ lib, pkgs }:

{
  # Zsh syntax highlighting plugin
  package = pkgs.zsh-syntax-highlighting;
  lazy = true;
  defer = 2;
  dependsOn = [ "zsh-autosuggestions" ];
  
  # Use zsh.plugins format for direct integration
  zshPlugin = {
    name = "zsh-syntax-highlighting";
    src = pkgs.zsh-syntax-highlighting;
    file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
  };
  
  after = ''
    # Custom syntax highlighting styles
    ZSH_HIGHLIGHT_STYLES[command]='fg=blue,bold'
    ZSH_HIGHLIGHT_STYLES[alias]='fg=magenta,bold'
    ZSH_HIGHLIGHT_STYLES[builtin]='fg=cyan,bold'
    ZSH_HIGHLIGHT_STYLES[function]='fg=green,bold'
    ZSH_HIGHLIGHT_STYLES[path]='fg=white,underline'
    ZSH_HIGHLIGHT_STYLES[globbing]='fg=yellow'
    ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=blue'
    ZSH_HIGHLIGHT_STYLES[command-substitution]='fg=magenta'
    ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]='fg=red'
    ZSH_HIGHLIGHT_STYLES[process-substitution]='fg=magenta'
    ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]='fg=red'
    ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=cyan'
    ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=cyan'
    ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=magenta'
    ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=yellow'
    ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=yellow'
    ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=yellow'
    ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=cyan'
    ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg=cyan'
    ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]='fg=cyan'
    ZSH_HIGHLIGHT_STYLES[redirection]='fg=red'
    ZSH_HIGHLIGHT_STYLES[comment]='fg=black,bold'
  '';
}