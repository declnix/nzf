{
  nzf.modules = [
    ({ config, lib, pkgs, ... }:
    let
      inherit (lib) mkEnableOption mkIf;
    in
    {
      options.nzf.zsh.autosuggestions.enable = mkEnableOption "zsh autosuggestions";

      config = mkIf (config.nzf.zsh.enable && config.nzf.zsh.autosuggestions.enable) {
        nzf.zsh.extraPlugins.nzf-autosuggestions.source =
          "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh";
      };
    })
  ];
}
