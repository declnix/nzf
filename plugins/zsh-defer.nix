{ lib, pkgs, config, ... }:

let
  inherit (config.programs) nzf;
  cfg = nzf.zsh-defer;

  allPlugins = nzf._internal.plugins ++ nzf.plugins;
  usesDefer = p: p.defer || lib.elem "zsh-defer" p.after;
in
{
  options.programs.nzf.zsh-defer = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf (cfg.enable || lib.any usesDefer allPlugins) {
    programs.nzf._internal.corePlugins = lib.mkBefore [{
      name = "zsh-defer";
      src = pkgs.zsh-defer;
      file = "share/zsh-defer/zsh-defer.plugin.zsh";
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
