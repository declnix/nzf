{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  nzf = import ../../lib {inherit lib;};
in
{
  options.programs.nzf.zsh-defer.enable = mkEnableOption "zsh-defer";

  config = mkIf config.programs.nzf.zsh-defer.enable {
    programs.nzf.plugins.zsh-defer =
      nzf.entryAnywhere "source ${pkgs.zsh-defer}/share/zsh-defer/zsh-defer.plugin.zsh";
  };
}
