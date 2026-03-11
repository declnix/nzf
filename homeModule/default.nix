{
  lib,
  config,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    mkDefault
    types
    concatStringsSep
    ;
  cfg = config.programs.nzf;
  nzf = import ../lib { inherit lib; };
in
{
  options.programs.nzf = {
    enable = mkEnableOption "nzf";

    plugins = mkOption {
      type = types.attrsOf types.anything;
      default = { };
    };
  };

  config = mkIf cfg.enable {
    programs.zsh.enable = mkDefault true;
    programs.zsh.initContent = nzf.resolveDag {
      name = "nzf";
      dag = cfg.plugins;
      mapResult = results: concatStringsSep "\n\n" (builtins.map (e: e.data) results);
    };
  };
}
