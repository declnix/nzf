{ lib, pkgs, config, ... }:

let
  cfg = config.programs.nzf.zsh-defer;
  allPlugins = config.programs.nzf._internal.plugins ++ config.programs.nzf.plugins;

  needed = lib.any (p: p.defer || lib.elem "zsh-defer" p.after) allPlugins;
  enabled = cfg.enable || needed;
in
{
  options.programs.nzf.zsh-defer = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf enabled {
    programs.nzf._internal.plugins = lib.mkBefore [{
      name = "zsh-defer";
      src = pkgs.zsh-defer;
      file = "zsh-defer.plugin.zsh";
      defer = false;
      after = [];
    }];

    programs.nzf._internal.middlewares = [
      (next: p: script:
        if p.defer then
          let
            innerResult = next p script;
            safeName = lib.replaceStrings ["-"] ["_"] p.name;
          in ''
            __nzf_${safeName}_load() {
              ${innerResult}
            }
            zsh-defer __nzf_${safeName}_load
          ''
        else next p script)
    ];
  };
}
