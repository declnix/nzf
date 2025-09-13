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

  transformPlugin =
    p:
    if p.defer then
      p
      // {
        after = p.after ++ [ "zsh-defer" ];
        config = ''
          __defer_${p.name}_load() {
            ${p.config}
          }
          zsh-defer __defer_${p.name}_load
        '';
      }
    else
      p;

  pluginsToList = ps: lib.mapAttrsToList (name: value: value // { inherit name; }) ps;

  addZshDeferPlugin =
    ps:
    let
      # check if any plugin has defer = true or has "zsh-defer" in its after array
      needsZshDefer = lib.any (p: p.defer == true || builtins.elem "zsh-defer" p.after) (
        lib.attrValues ps
      );
    in
    if needsZshDefer then
      { "zsh-defer" = import ./plugins/zsh-defer.nix { inherit pkgs; }; } // ps
    else
      ps;

  transformDeferredPlugins = ps: map transformPlugin ps;

  sortPlugins =
    ps: (lib.lists.toposort (a: b: lib.any (pluginName: pluginName == a.name) b.after) ps).result;

  generateScript = ps: lib.concatStringsSep "\n" (map (p: p.config) ps);

  _zshInit = lib.pipe cfg.plugins [
    addZshDeferPlugin
    pluginsToList
    transformDeferredPlugins
    sortPlugins
    generateScript
  ];
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

  config = mkIf cfg.enable { programs.nzf._zshInit = _zshInit; };
}
