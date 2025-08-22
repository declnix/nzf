{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkOption types mkIf;
  inherit (lib.attrsets) attrValues;
  cfg = config.programs.nzf;
in
{
  options.programs.nzf = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable nzf, an extensible zsh configuration wrapper.";
    };

    plugins = mkOption {
      type = with types; attrsOf (attrsOf anything);
      default = { };
      description = "Attribute set of Zsh plugins to load with nzf.";
    };
  };

  config = mkIf cfg.enable {
    programs.zsh = {
      initExtra = lib.concatStringsSep "\n" (
        builtins.map (p: p.config) (builtins.attrValues cfg.plugins)
      );
      enable = true;
    };
  };
}
