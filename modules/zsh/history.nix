{
  nzf.modules = [
    ({ config, lib, ... }:
    let
      inherit (lib) concatStringsSep mkEnableOption mkIf mkOption types;
      cfg = config.nzf.zsh.history;
    in
    {
      options.nzf.zsh.history = {
        enable = mkEnableOption "zsh history";

        file = mkOption {
          type = types.str;
          default = "$HOME/.zsh_history";
          description = "HISTFILE path, using zsh syntax.";
        };

        size = mkOption {
          type = types.int;
          default = 50000;
          description = "HISTSIZE value.";
        };

        save = mkOption {
          type = types.int;
          default = 50000;
          description = "SAVEHIST value.";
        };

        options = mkOption {
          type = types.listOf types.str;
          default = [
            "APPEND_HISTORY"
            "HIST_IGNORE_SPACE"
            "HIST_IGNORE_ALL_DUPS"
            "HIST_SAVE_NO_DUPS"
            "HIST_FIND_NO_DUPS"
          ];
          description = "History-related zsh options.";
        };
      };

      config = mkIf (config.nzf.zsh.enable && cfg.enable) {
        nzf.zsh.snippets.nzf-history.text = ''
          HISTFILE="${cfg.file}"
          HISTSIZE=${toString cfg.size}
          SAVEHIST=${toString cfg.save}
          [[ -d "''${HISTFILE:h}" ]] || mkdir -p "''${HISTFILE:h}"
          ${concatStringsSep "\n" (map (option: "setopt ${option}") cfg.options)}
        '';
      };
    })
  ];
}
