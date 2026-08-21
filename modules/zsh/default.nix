{ lib, ... }:

{
  nzf.modules = [
    ({ config, dag, lib, pkgs, ... }:
    let
      inherit (lib)
        concatStringsSep
        filterAttrs
        mapAttrs
        mapAttrsToList
        mkEnableOption
        mkIf
        mkOption
        optional
        types
        ;
      cfg = config.nzf.zsh;

      entryType = types.submodule {
        options = {
          enable = mkOption {
            type = types.bool;
            default = true;
            description = "Whether to render this NZF entry.";
          };

          text = mkOption {
            type = types.lines;
            default = "";
            description = "Zsh code rendered for this NZF entry.";
          };

          after = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "NZF entries that must render before this entry.";
          };

          before = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "NZF entries that must render after this entry.";
          };

          defer = mkOption {
            type = types.bool;
            default = false;
            description = "Whether this entry should be loaded through zsh-defer.";
          };
        };
      };

      pluginType = types.submodule {
        options = {
          enable = mkOption {
            type = types.bool;
            default = true;
            description = "Whether to render this NZF plugin.";
          };

          source = mkOption {
            type = types.nullOr (types.either types.path types.str);
            default = null;
            description = "Path to the plugin file to source.";
          };

          completions = mkOption {
            type = types.listOf (types.either types.path types.str);
            default = [ ];
            description = "Completion directories added to fpath before sourcing the plugin.";
          };

          config = mkOption {
            type = types.lines;
            default = "";
            description = "Zsh code rendered after the plugin source.";
          };

          after = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "NZF entries that must render before this plugin.";
          };

          before = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "NZF entries that must render after this plugin.";
          };

          defer = mkOption {
            type = types.bool;
            default = false;
            description = "Whether this plugin should be loaded through zsh-defer.";
          };
        };
      };

      renderPlugin = plugin:
        concatStringsSep "\n" (
          (map (path: "fpath=(${path} $fpath)") plugin.completions)
          ++ optional (plugin.source != null) "source ${plugin.source}"
          ++ optional (plugin.config != "") plugin.config
        );

      pluginEntries = mapAttrs
        (_: plugin: {
          inherit (plugin) enable after before defer;
          text = renderPlugin plugin;
        })
        cfg.extraPlugins;

      entries = filterAttrs (_: entry: entry.enable && entry.text != "") (cfg.snippets // pluginEntries);
      functionName = name:
        "_nzf_defer_${builtins.replaceStrings [ "-" "." "/" ] [ "_" "_" "_" ] name}";

      renderEntry = name: entry:
        if entry.defer then
          ''
            ${functionName name}() {
              ${entry.text}
            }
            zsh-defer ${functionName name}
          ''
        else
          entry.text;

      toDagEntry = name: entry: {
        inherit name;
        value =
          if entry.after != [ ] then
            dag.entryAfter entry.after (renderEntry name entry)
          else if entry.before != [ ] then
            dag.entryBefore entry.before (renderEntry name entry)
          else
            dag.entryAnywhere (renderEntry name entry);
      };

      renderedDag = dag.render {
        entries = lib.listToAttrs (mapAttrsToList toDagEntry entries);
      };
    in
    {
      options.assertions = mkOption {
        type = types.listOf (types.submodule {
          options = {
            assertion = mkOption {
              type = types.bool;
              description = "Whether the assertion passed.";
            };
            message = mkOption {
              type = types.str;
              description = "Message to show when the assertion fails.";
            };
          };
        });
        default = [ ];
        description = "Assertions checked after NZF module evaluation.";
      };

      options.nzf.zsh = {
        enable = mkEnableOption "NZF zsh configuration";

        initConfig = mkOption {
          type = types.lines;
          default = "";
          description = "Raw zsh code rendered after NZF managed plugin entries.";
        };

        setOptions = mkOption {
          type = types.listOf types.str;
          default = [ ];
          description = "Zsh options enabled with setopt.";
        };

        unsetOptions = mkOption {
          type = types.listOf types.str;
          default = [ ];
          description = "Zsh options disabled with unsetopt.";
        };

        snippets = mkOption {
          type = types.attrsOf entryType;
          default = { };
          description = "Named NZF DAG snippets rendered into zsh init.";
        };

        extraPlugins = mkOption {
          type = types.attrsOf pluginType;
          default = { };
          description = "Named custom NZF DAG plugins rendered into zsh init.";
        };

        renderedRc = mkOption {
          type = types.lines;
          internal = true;
          default = "";
          description = "Rendered .zshrc contents.";
        };
      };

      config = mkIf cfg.enable {
        nzf.zsh.snippets.nzf-options = {
          enable = cfg.setOptions != [ ] || cfg.unsetOptions != [ ];
          text = concatStringsSep "\n" (
            (map (option: "setopt ${option}") cfg.setOptions)
            ++ (map (option: "unsetopt ${option}") cfg.unsetOptions)
          );
        };

        nzf.zsh.extraPlugins.nzf-zsh-defer = {
          source = "${pkgs.zsh-defer}/share/zsh-defer/zsh-defer.plugin.zsh";
        };

        nzf.zsh.renderedRc = ''
          ${renderedDag}
          ${cfg.initConfig}
        '';
      };
    })
  ];
}
