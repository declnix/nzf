{
  nzf.modules = [
    ({ config, lib, nzfZshPlugins, ... }:
    let
      inherit (lib) mkEnableOption mkIf;
      cfg = config.nzf.zsh.plugins.docker;
    in
    {
      options.nzf.zsh.plugins.docker.enable = mkEnableOption "the docker zsh polyfill";

      config = mkIf (config.nzf.zsh.enable && cfg.enable) {
        nzf.zsh.plugins.functions.enable = true;

        nzf.zsh.extraPlugins.nzf-plugin-docker = {
          source = nzfZshPlugins.omzPlugin "docker";
          after = [ "nzf-plugin-functions-lib" ];
          defer = true;
        };
      };
    })
  ];
}
