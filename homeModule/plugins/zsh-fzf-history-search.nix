{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkDefault;
  nzf = import ../../lib { inherit lib; };
  inherit (nzf) entryAfter defer plugin;
  cfg = config.programs.nzf.zsh-fzf-history-search;
in
{
  options.programs.nzf.zsh-fzf-history-search.enable = mkEnableOption "zsh-fzf-history-search";

  config = mkIf cfg.enable {
    programs.nzf = {
      plugins.zsh-fzf-history-search = entryAfter [ "zsh-defer" ] (
        defer (plugin pkgs.zsh-fzf-history-search)
      );
      zsh-defer.enable = mkDefault true;
    };
    home.packages = [ pkgs.fzf ];
  };
}
