{ lib, pkgs }:

let
  inherit (lib) mkOption types;
  
  # Import individual lib modules
  dag = import ./dag.nix { inherit lib; };
  lazyLoading = import ./lazy-loading.nix { inherit lib pkgs; };
  moduleSystem = import ./module-system.nix { inherit lib pkgs; };
  
in rec {
  # Re-export all modules
  inherit (dag) mkDAG sortDAG;
  inherit (lazyLoading) mkLazyPlugin generateDeferredLoading;
  inherit (moduleSystem) mkZhfModule evalZhfConfig;

  # Plugin types
  pluginType = types.submodule ({ config, name, ... }: {
    options = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to enable this plugin";
      };

      package = mkOption {
        type = types.nullOr types.package;
        default = null;
        description = "Plugin package to use";
      };

      lazy = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to load this plugin lazily";
      };

      defer = mkOption {
        type = types.nullOr types.int;
        default = null;
        description = "Defer loading by N seconds";
      };

      dependsOn = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "List of plugins this depends on";
      };

      before = mkOption {
        type = types.lines;
        default = "";
        description = "Shell code to run before loading plugin";
      };

      after = mkOption {
        type = types.lines;
        default = "";
        description = "Shell code to run after loading plugin";
      };

      env = mkOption {
        type = types.attrsOf types.str;
        default = {};
        description = "Environment variables to set";
      };

      keys = mkOption {
        type = types.listOf (types.submodule {
          options = {
            key = mkOption {
              type = types.str;
              description = "Key binding";
            };
            mode = mkOption {
              type = types.listOf (types.enum ["n" "i" "v" "c"]);
              default = ["n"];
              description = "Modes for the key binding";
            };
            action = mkOption {
              type = types.str;
              description = "Action to execute";
            };
            desc = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Description of the key binding";
            };
          };
        });
        default = [];
        description = "Key bindings for this plugin";
      };

      config = mkOption {
        type = types.attrs;
        default = {};
        description = "Plugin-specific configuration";
      };
    };
  });

  # Main configuration builder
  buildConfig = config: 
    let
      enabledPlugins = lib.filterAttrs (n: v: v.enable) config.plugins;
      sortedPlugins = sortDAG enabledPlugins;
      
      # Generate shell initialization script
      initScript = generateInitScript sortedPlugins config.settings;
      
    in {
      inherit initScript sortedPlugins;
      zshrc = generateZshrc config;
    };

  # Generate the main zshrc content
  generateZshrc = config: ''
    # ZHF Generated Configuration
    # Generated at: ${builtins.toString builtins.currentTime}
    
    ${lib.optionalString config.settings.enableStartupProfiling ''
      # Startup profiling
      zmodload zsh/zprof
    ''}
    
    # Core ZHF setup
    export ZHF_ROOT="${config.settings.zhfRoot or "$HOME/.config/zhf"}"
    export ZHF_CACHE_DIR="''${ZHF_ROOT}/cache"
    mkdir -p "$ZHF_CACHE_DIR"
    
    # Source defer function if available
    if [[ -f "${pkgs.zsh-defer}/share/zsh-defer/zsh-defer.plugin.zsh" ]]; then
      source "${pkgs.zsh-defer}/share/zsh-defer/zsh-defer.plugin.zsh"
    fi
    
    # Global settings
    ${generateGlobalSettings config.settings}
    
    # Plugin initialization
    ${buildConfig config}.initScript
    
    ${lib.optionalString config.settings.enableStartupProfiling ''
      # End profiling
      if [[ "$ZHF_PROFILE" == "1" ]]; then
        zprof
      fi
    ''}
  '';

  # Generate global zsh settings
  generateGlobalSettings = settings: ''
    # History configuration
    ${lib.optionalString (settings.history.enable or true) ''
      HISTFILE="''${ZHF_ROOT}/history"
      HISTSIZE=${toString (settings.history.size or 10000)}
      SAVEHIST=${toString (settings.history.save or 10000)}
      setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE SHARE_HISTORY
    ''}
    
    # Completion system
    ${lib.optionalString (settings.completion.enable or true) ''
      autoload -Uz compinit
      compinit -d "''${ZHF_CACHE_DIR}/zcompdump"
      
      # Enhanced completion
      setopt COMPLETE_IN_WORD ALWAYS_TO_END
      zstyle ':completion:*' menu select
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
    ''}
    
    # Directory navigation
    ${lib.optionalString (settings.navigation.enable or true) ''
      setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS
      alias ..='cd ..'
      alias ...='cd ../..'
      alias ....='cd ../../..'
    ''}
    
    # Custom aliases
    ${lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "alias ${k}='${v}'") (settings.aliases or {}))}
    
    # Custom environment variables
    ${lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "export ${k}='${v}'") (settings.env or {}))}
  '';

  # Generate plugin initialization script
  generateInitScript = plugins: settings:
    let
      pluginInits = lib.mapAttrsToList (name: plugin: 
        generatePluginInit name plugin
      ) plugins;
    in lib.concatStringsSep "\n\n" pluginInits;

  # Generate initialization code for a single plugin
  generatePluginInit = name: plugin:
    let
      envVars = lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "export ${k}='${v}'") plugin.env);
      keyBindings = lib.concatStringsSep "\n" (map generateKeyBinding plugin.keys);
      
      loadCommand = ''
        # Load plugin: ${name}
        ${envVars}
        ${plugin.before}
        
        ${if plugin.package != null then ''
          # Source from package
          if [[ -f "${plugin.package}/share/zsh/${name}/${name}.plugin.zsh" ]]; then
            source "${plugin.package}/share/zsh/${name}/${name}.plugin.zsh"
          elif [[ -f "${plugin.package}/share/${name}.zsh" ]]; then
            source "${plugin.package}/share/${name}.zsh"
          fi
        '' else ''
          # Plugin loading logic would go here for custom plugins
          echo "Warning: No package specified for plugin ${name}"
        ''}
        
        ${plugin.after}
        ${keyBindings}
      '';
      
    in if plugin.lazy then ''
      # Lazy load: ${name}
      ${if plugin.defer != null then ''
        zsh-defer -t ${toString plugin.defer} -c '${lib.replaceStrings ["\n"] ["; "] loadCommand}'
      '' else ''
        zsh-defer -c '${lib.replaceStrings ["\n"] ["; "] loadCommand}'
      ''}
    '' else loadCommand;

  # Generate key binding
  generateKeyBinding = binding: ''
    bindkey '${binding.key}' ${binding.action}
  '';
}