{
  nzf.modules = [
    ({ config, lib, pkgs, ... }:
    let
      inherit (lib) mkEnableOption mkIf;
    in
    {
      options.nzf.zsh.viMode.enable = mkEnableOption "zsh vi mode";

      config = mkIf (config.nzf.zsh.enable && config.nzf.zsh.viMode.enable) {
        nzf.zsh.extraPlugins.nzf-vi-mode.source =
          "${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      };
    })
  ];
}
