{
  nzf.modules = [
    ({ config, lib, nzfZshPlugins, ... }:
    let
      inherit (lib) mkEnableOption mkIf;
      cfg = config.nzf.zsh.plugins.git;
    in
    {
      options.nzf.zsh.plugins.git.enable = mkEnableOption "the git zsh polyfill";

      config = mkIf (config.nzf.zsh.enable && cfg.enable) {
        nzf.zsh.plugins.functions.enable = true;

        nzf.zsh.extraPlugins = {
          nzf-plugin-git-lib = {
            source = nzfZshPlugins.omzLib "git";
            after = [ "nzf-plugin-functions-lib" ];
            defer = true;
          };

          nzf-plugin-git = {
            source = nzfZshPlugins.omzPlugin "git";
            after = [ "nzf-plugin-git-lib" ];
            defer = true;
          };
        };
      };
    })
  ];
}
