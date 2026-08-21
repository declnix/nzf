{
  nzf.modules = [
    ({ config, lib, ... }:
    let
      inherit (lib) mkEnableOption mkIf mkOption types;
      cfg = config.nzf.zsh.completion;
    in
    {
      options.nzf.zsh.completion = {
        enable = mkEnableOption "zsh completion";

        initConfig = mkOption {
          type = types.lines;
          default = "";
          description = "Extra completion configuration rendered after compinit.";
        };
      };

      config = mkIf (config.nzf.zsh.enable && cfg.enable) {
        nzf.zsh.snippets.nzf-completion.text = ''
          autoload -Uz compinit
          compinit
          ${cfg.initConfig}
        '';
      };
    })
  ];
}
