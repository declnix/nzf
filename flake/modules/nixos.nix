{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf;
  cfg = config.programs.nzf;
in
{
  imports = [ ../../modules/nzf.nix ];

  config = mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      initExtra = cfg._zshInit;
    };

    environment.systemPackages = lib.concatMap (p: p.extraPackages) (lib.attrValues cfg.plugins);
  };
}
