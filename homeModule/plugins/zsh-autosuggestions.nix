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
  cfg = config.programs.nzf.zsh-autosuggestions;
in
{
  options.programs.nzf.zsh-autosuggestions.enable = mkEnableOption "zsh-autosuggestions";
  options.programs.nzf.autosuggestion.enable = mkEnableOption "zsh-autosuggestions";

  config = mkIf (cfg.enable || config.programs.nzf.autosuggestion.enable) {
    programs.nzf.zsh-defer.enable = mkDefault true;
    programs.nzf.plugins.zsh-autosuggestions = entryAfter [ "zsh-defer" ] (
      defer (plugin pkgs.zsh-autosuggestions)
    );
  };
}
