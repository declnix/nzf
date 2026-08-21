{
  nzf.modules = [
    ({ config, lib, nzfZshPlugins, ... }:
    let
      inherit (lib) mkEnableOption mkIf;
      cfg = config.nzf.zsh.plugins.grep;
    in
    {
      options.nzf.zsh.plugins.grep.enable = mkEnableOption "the grep zsh polyfill";

      config = mkIf (config.nzf.zsh.enable && cfg.enable) {
        nzf.zsh.plugins.functions.enable = true;

        nzf.zsh.extraPlugins.nzf-plugin-grep-lib = {
          source = nzfZshPlugins.omzLib "grep";
          after = [ "nzf-plugin-functions-lib" ];
          defer = true;
        };
      };
    })
  ];
}
