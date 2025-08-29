{
  lib,
  pkgs,
  config,
  ...
}:

let
  inherit (lib) types mkOption mkIf;
  cfg = config.programs.nzf;
  customTypes = import ../lib/types.nix { inherit lib pkgs; };
  zsh-defer = import ./plugins/zsh-defer.nix { inherit lib pkgs; }; 
in
{
  options.programs.nzf = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable nzf, an extensible zsh configuration wrapper.";
    };

    plugins = mkOption {
      type = with types; attrsOf customTypes.plugin;
      default = { };
      description = "Attribute set of Zsh plugins to load with nzf.";
    };

    _zshInit = mkOption {
      type = types.lines;
      internal = true;
      description = "The generated Zsh initialization script (for internal use).";
    };
  };

  config = mkIf cfg.enable {
    programs.nzf._zshInit =
      let
        pluginList = lib.mapAttrsToList (name: value: value // { inherit name; }) ({ inherit zsh-defer; } // cfg.plugins);
        transformedPlugins = map (
          p:
          if p.defer == true then
            p
            // {
              after = p.after ++ [ pkgs.zsh-defer ];
              config = ''
                __defer_${p.name}_load() {
                ${p.config}
                }
                zsh-defer __defer_${p.name}_load
              '';
            }
          else
            p
        ) pluginList;
        sortedPlugins = (lib.lists.toposort (a: b: builtins.elem a.name b.after) transformedPlugins).result;
      in
      lib.concatStringsSep "
" (map (p: p.config) sortedPlugins);
  };
}
