{ lib, pkgs, config, ... }:

let
  mainCfg   = config.programs.nzf.zsh-autosuggestions;
  compatCfg = config.programs.nzf.autosuggestion;

  enabled =
    (mainCfg.enable or false) ||
    (compatCfg.enable or false);
in
{
  ############################################################
  # Primary plugin namespace
  ############################################################

  options.programs.nzf.zsh-autosuggestions = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };

    defer = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  ############################################################
  # Compatibility alias (like classic zsh)
  ############################################################

  options.programs.nzf.autosuggestion.enable =
    lib.mkOption {
      type = lib.types.bool;
      default = false;
    };

  ############################################################
  # Register plugin into core when enabled
  ############################################################

  config = lib.mkIf enabled {
    programs.nzf._internal.plugins = lib.mkAfter [
      {
        name = "zsh-autosuggestions";
        src = pkgs.zsh-autosuggestions;
        file = "share/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh";
        defer = mainCfg.defer or false;
        after = [];
      }
    ];
  };
}