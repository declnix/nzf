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
    programs.nzf.plugins.omz-lib-git = entryAfter [ "zsh-defer" ] (
      defer ''
        source ${omz}/share/oh-my-zsh/lib/git.zsh
      ''
    );
  };
}
