{ config, lib, ... }:
let
  inherit (lib.options) mkEnableOption;
  inherit (lib.modules) mkIf;

  cfg = config.programs.nzf;

in
{
  options.programs.nzf = {
    enable = mkEnableOption "nzf, extensible zsh configuration wrapper";
  };

  config = mkIf cfg.enable {
    programs.zsh = {
      initContent = ''
        echo "Hello world!"
      '';
    };
  };
}
