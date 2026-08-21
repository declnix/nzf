{
  nzf.modules = [
    ({ config, lib, pkgs, ... }:
    let
      inherit (lib) mkEnableOption mkIf optional;
      cfg = config.nzf.zsh.highlighting.integrations.patina;
      package = pkgs.zsh-patina;
    in
    {
      options.nzf.zsh.highlighting.integrations.patina.enable = mkEnableOption "zsh-patina highlighting integration";

      config = mkIf (config.nzf.zsh.enable && config.nzf.zsh.highlighting.enable && cfg.enable) {
        nzf.zsh.snippets.nzf-highlighting = {
          after = optional config.nzf.zsh.autosuggestions.enable "nzf-autosuggestions";
          text = ''eval "$(${package}/bin/zsh-patina activate)"'';
        };
      };
    })
  ];
}
