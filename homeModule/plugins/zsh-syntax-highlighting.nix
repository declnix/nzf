{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkDefault optional;
  nzf = import ../../lib {inherit lib;};
  inherit (nzf) entryAfter defer pluginFile;
  cfg = config.programs.nzf.zsh-syntax-highlighting;
  autosuggestions = config.programs.nzf.zsh-autosuggestions;
  pkg = pkgs.zsh-syntax-highlighting;
in
{
  options.programs.nzf.zsh-syntax-highlighting.enable = mkEnableOption "zsh-syntax-highlighting";

  config = mkIf cfg.enable {
    programs.nzf.zsh-defer.enable = mkDefault true;
    programs.nzf.plugins.zsh-syntax-highlighting =
      entryAfter (["zsh-defer"] ++ optional autosuggestions.enable "zsh-autosuggestions")
        (defer (pluginFile pkg "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"));
  };
}
