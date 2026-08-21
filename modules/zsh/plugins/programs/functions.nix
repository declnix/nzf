{
  nzf.modules = [
    ({ config, lib, nzfZshPlugins, ... }:
    let
      inherit (lib) mkEnableOption mkIf;
      cfg = config.nzf.zsh.plugins.functions;
    in
    {
      options.nzf.zsh.plugins.functions.enable = mkEnableOption "the functions zsh polyfill";

      config = mkIf (config.nzf.zsh.enable && cfg.enable) {
        nzf.zsh.extraPlugins.nzf-plugin-functions-lib = {
          source = nzfZshPlugins.omzLib "functions";
          defer = true;
        };
      };
    })
  ];
}
