{
  nzf.modules = [
    ({ config, lib, nzfZshPlugins, ... }:
    let
      inherit (lib) mkEnableOption mkIf;
      cfg = config.nzf.zsh.plugins.docker-compose;
    in
    {
      options.nzf.zsh.plugins.docker-compose.enable = mkEnableOption "the docker-compose zsh polyfill";

      config = mkIf (config.nzf.zsh.enable && cfg.enable) {
        nzf.zsh.plugins.docker.enable = true;

        nzf.zsh.extraPlugins.nzf-plugin-docker-compose = {
          source = nzfZshPlugins.omzPlugin "docker-compose";
          after = [ "nzf-plugin-docker" ];
          defer = true;
        };
      };
    })
  ];
}
