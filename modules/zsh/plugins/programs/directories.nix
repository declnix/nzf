{
  nzf.modules = [
    ({ config, lib, nzfZshPlugins, ... }:
    let
      inherit (lib) mkEnableOption mkIf;
      cfg = config.nzf.zsh.plugins.directories;
    in
    {
      options.nzf.zsh.plugins.directories.enable = mkEnableOption "the directories zsh polyfill";

      config = mkIf (config.nzf.zsh.enable && cfg.enable) {
        nzf.zsh.plugins.functions.enable = true;

        nzf.zsh.extraPlugins.nzf-plugin-directories-lib = {
          source = nzfZshPlugins.omzLib "directories";
          after = [ "nzf-plugin-functions-lib" ];
          defer = true;
        };
      };
    })
  ];
}
