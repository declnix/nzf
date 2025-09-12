{ pkgs, lib, ... }: {
  programs.nzf = {
    plugins = with pkgs; {
      zsh-fzf-tab = rec {
        enable = true;

        config = ''
          source ${zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
        '';

        defer = true;

        extraPackages = [ fzf ];
      };

      zsh-vi-mode = rec {
        enable = true;

        config = ''
          source ${zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
        '';
      };

      zsh-fzf-history-search = {
        enable = true;

        config = ''
          source ${zsh-fzf-history-search}/share/zsh-fzf-history-search/zsh-fzf-history-search.plugin.zsh
        '';
        defer = true;
        extraPackages = [ fzf ];
        # Ensure zsh-fzf-history-search loads after zsh-vi-mode to prevent keybinding conflicts.
        after = [ "zsh-vi-mode" ];
      };

    };
    enable = true;
  };
}
