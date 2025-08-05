{ lib, pkgs }:

{
  # FZF Tab completion plugin
  package = pkgs.zsh-fzf-tab;
  lazy = true;
  defer = 1;
  dependsOn = [ ];
  
  # Use zsh.plugins format for direct integration
  zshPlugin = {
    name = "fzf-tab";
    src = pkgs.zsh-fzf-tab;
    file = "share/fzf-tab/fzf-tab.plugin.zsh";
  };
  
  after = ''
    # FZF-tab configuration
    # disable sort when completing `git checkout`
    zstyle ':completion:*:git-checkout:*' sort false
    
    # set descriptions format to enable group support
    zstyle ':completion:*:descriptions' format '[%d]'
    
    # set list-colors to enable filename colorizing
    zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
    
    # preview directory's content with eza when completing cd
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
    
    # switch group using `,` and `.`
    zstyle ':fzf-tab:*' switch-group ',' '.'
    
    # preview for kill command
    zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview \
      '[[ $group == "[process ID]" ]] && ps --pid=$word -o cmd --no-headers -w -w'
    zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-flags --preview-window=down:3:wrap
    
    # preview for git
    zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview \
      'git diff $word | delta'
    zstyle ':fzf-tab:complete:git-log:*' fzf-preview \
      'git log --color=always $word'
    zstyle ':fzf-tab:complete:git-help:*' fzf-preview \
      'git help $word | bat -plman --color=always'
    zstyle ':fzf-tab:complete:git-show:*' fzf-preview \
      'case "$group" in
      "commit tag") git show --color=always $word ;;
      *) git show --color=always $word | delta ;;
      esac'
    zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview \
      'case "$group" in
      "modified file") git diff $word | delta ;;
      "recent commit object name") git show --color=always $word | delta ;;
      *) git log --color=always $word ;;
      esac'
  '';
  
  # Additional programs that work well with fzf-tab
  programs = {
    eza = {
      enable = true;
      enableZshIntegration = true;
    };
  };

  programs = {
    fzf.enable = true;
  };
}