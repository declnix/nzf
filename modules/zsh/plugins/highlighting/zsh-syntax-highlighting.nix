{
  nzf.modules = [
    ({ config, lib, pkgs, ... }:
    let
      inherit (lib) mkEnableOption mkIf optional;
      cfg = config.nzf.zsh.highlighting.integrations.zshSyntaxHighlighting;
    in
    {
      options.nzf.zsh.highlighting.integrations.zshSyntaxHighlighting.enable =
        mkEnableOption "zsh-syntax-highlighting integration";

      config = mkIf (config.nzf.zsh.enable && config.nzf.zsh.highlighting.enable && cfg.enable) {
        nzf.zsh.extraPlugins.nzf-highlighting = {
          after = optional config.nzf.zsh.autosuggestions.enable "nzf-autosuggestions";
          source = "${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
        };
      };
    })
  ];
}
