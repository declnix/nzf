{ lib, config, pkgs, inputs, ... }:

let
  inherit (lib) mkOption mkIf types;

  cfg = config.programs.nzf;

  pluginModules = builtins.attrValues inputs.self.plugins;

  ############################################################
  # Plugin definition type
  ############################################################

  pluginType = types.submodule {
    options = {
      name = mkOption { type = types.str; };
      src  = mkOption { type = types.path; };
      file = mkOption { type = types.str; };

      defer = mkOption {
        type = types.bool;
        default = false;
      };

      after = mkOption {
        type = types.listOf types.str;
        default = [];
      };
    };
  };

  ############################################################
  # Merge framework plugins with user overrides
  ############################################################

  toMap = list:
    builtins.listToAttrs
      (map (p: { name = p.name; value = p; }) list);

  frameworkMap = toMap cfg._internal.plugins;
  userMap      = toMap cfg.plugins;

  # User plugins override framework plugins by name
  mergedMap = frameworkMap // userMap;

  mergedPlugins =
    builtins.attrValues mergedMap;

  ############################################################
  # Auto bootstrap zsh-defer if needed
  ############################################################

  needsDefer =
    lib.any (p: p.defer) mergedPlugins;

  withDefer =
    if needsDefer then
      mergedPlugins ++ [{
        name = "zsh-defer";
        src = pkgs.zsh-defer;
        file = "zsh-defer.plugin.zsh";
        defer = false;
        after = [];
      }]
    else
      mergedPlugins;

  ############################################################
  # DAG ordering
  ############################################################

  sorted =
    (lib.lists.toposort
      (a: b: lib.elem a.name b.after)
      withDefer
    ).result;

  ############################################################
  # Generate init script
  ############################################################

  toScript = p:
    let
      sourceLine = "source ${p.src}/${p.file}";
    in
    if p.defer then ''
      __nzf_${p.name}_load() {
        ${sourceLine}
      }
      zsh-defer __nzf_${p.name}_load
    '' else
      sourceLine;

  generated =
    lib.concatStringsSep "\n" (map toScript sorted);

in
{
  imports = pluginModules;

  options.programs.nzf = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };

    # Framework plugins register themselves here
    _internal.plugins = mkOption {
      type = types.listOf pluginType;
      default = [];
      internal = true;
    };

    # User custom plugins and overrides
    plugins = mkOption {
      type = types.listOf pluginType;
      default = [];
    };
  };

  config = mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      initExtra = generated;
    };
  };
}