{
  nzf.modules = [
    ({ config, lib, nzfZshPlugins, ... }:
    let
      inherit (lib) mkEnableOption mkIf;
      cfg = config.nzf.zsh.plugins.maven;
    in
    {
      options.nzf.zsh.plugins.maven.enable = mkEnableOption "the Maven zsh polyfill";

      config = mkIf (config.nzf.zsh.enable && cfg.enable) {
        nzf.zsh.extraPlugins.nzf-plugin-maven = {
          source = nzfZshPlugins.omzPlugin "mvn";
          defer = true;
        };
      };
    })
  ];
}
