{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkIf mkDefault elem;
  nzf = import ../../../../lib { inherit lib; };
  inherit (nzf) entryAfter defer;
  cfg = config.programs.nzf.oh-my-zsh;
  omz = pkgs.oh-my-zsh;
  enabled = elem "git" cfg.plugins;
in
{
  config = mkIf enabled {
    programs.nzf.zsh-defer.enable = mkDefault true;
    programs.nzf.plugins.omz-git = entryAfter [ "omz-lib-git" ] (
      defer ''
        source ${omz}/share/oh-my-zsh/plugins/git/git.plugin.zsh
      ''
    );
  };
}
