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
  zsh-defer-module = import ./plugins/zsh-defer.nix { inherit lib pkgs; };

  zshDeferPlugin = {
    name = "zsh-defer";
    config = zsh-defer-module.config;
    after = [ ];
    defer = false;
  };

  transformPlugin =
    p:
    if p.defer then
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
      p;

  userPlugins = lib.mapAttrsToList (name: value: value // { inherit name; }) cfg.plugins;

  needsZshDefer =
    lib.any (p: p.defer) userPlugins || lib.any (p: builtins.elem pkgs.zsh-defer p.after) userPlugins;

  allPlugins =
    if needsZshDefer && !(lib.any (p: p.name == "zsh-defer") userPlugins) then
      userPlugins ++ [ zshDeferPlugin ]
    else
      userPlugins;

  transformedPlugins = map transformPlugin allPlugins;

  sortedPlugins =
    (lib.lists.toposort (a: b: lib.any (pluginName: pluginName == a.name) b.after) transformedPlugins).result;
in
{
  options.programs.nzf = 
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
    programs.nzf._zshInit = lib.concatStringsSep "\n" (map (p: p.config) sortedPlugins);
  };
}
