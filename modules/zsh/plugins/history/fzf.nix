{
  nzf.modules = [
    ({ config, lib, pkgs, ... }:
    let
      inherit (lib) mkEnableOption mkIf;
      cfg = config.nzf.zsh.history.integrations.fzf;
    in
    {
      options.nzf.zsh.history.integrations.fzf.enable = mkEnableOption "fzf history integration";

      config = mkIf (config.nzf.zsh.enable && cfg.enable) {
        nzf.zsh.extraPlugins.nzf-fzf-history = {
          after = [
            "nzf-history"
            "nzf-zsh-defer"
          ];
          defer = true;
          source = "${pkgs.zsh-fzf-history-search}/share/zsh-fzf-history-search/zsh-fzf-history-search.plugin.zsh";
        };
      };
    })
  ];
}
