{
  nzf.modules = [
    ({ config, lib, nzfZshPlugins, ... }:
    let
      inherit (lib) mkEnableOption mkIf;
      cfg = config.nzf.zsh.plugins.npm;
    in
    {
      options.nzf.zsh.plugins.npm.enable = mkEnableOption "the npm zsh polyfill";

      config = mkIf (config.nzf.zsh.enable && cfg.enable) {
        nzf.zsh.extraPlugins.nzf-plugin-npm = {
          source = nzfZshPlugins.omzPlugin "npm";
          defer = true;
        };
      };
    })
  ];
}
