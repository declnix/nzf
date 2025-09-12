{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf;
  cfg = config.programs.nzf;
in {
  imports = [ ../modules/nzf.nix ];

  config = mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      initContent = cfg._zshInit;
    };

    home.packages =
      lib.concatMap (p: p.extraPackages) (lib.attrValues cfg.plugins);
  };
}
