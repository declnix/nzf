{ lib, pkgs }:

let
  inherit (lib) mkOption types;
  
  # Define the main ZHF module type
  zhfModuleType = types.submodule {
    options = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to enable ZHF";
      };
      
      settings = mkOption {
        type = types.submodule {
          options = {
            zhfRoot = mkOption {
              type = types.str;
              default = "$HOME/.zhf";
              description = "ZHF root directory";
            };
            
            enableStartupProfiling = mkOption {
              type = types.bool;
              default = false;
              description = "Enable startup profiling with zprof";
            };
            
            history = mkOption {
              type = types.submodule {
                options = {
                  enable = mkOption {
                    type = types.bool;
                    default = true;
                    description = "Enable history configuration";
                  };
                  
                  size = mkOption {
                    type = types.int;
                    default = 10000;
                    description = "History size in memory";
                  };
                  
                  save = mkOption {
                    type = types.int;
                    default = 10000;
                    description = "History size on disk";
                  };
                };
              };
              default = {};
              description = "History configuration";
            };
            
            completion = mkOption {
              type = types.submodule {
                options = {
                  enable = mkOption {
                    type = types.bool;
                    default = true;
                    description = "Enable completion system";
                  };
                  
                  fuzzy = mkOption {
                    type = types.bool;
                    default = true;
                    description = "Enable fuzzy completion matching";
                  };
                };
              };
              default = {};
              description = "Completion configuration";
            };
            
            navigation = mkOption {
              type = types.submodule {
                options = {
                  enable = mkOption {
                    type = types.bool;
                    default = true;
                    description = "Enable enhanced directory navigation";
                  };
                };
              };
              default = {};
              description = "Navigation configuration";
            };
            
            aliases = mkOption {
              type = types.attrsOf types.str;
              default = {};
              example = { ll = "ls -la"; la = "ls -A"; };
              description = "Shell aliases";
            };
            
            env = mkOption {
              type = types.attrsOf types.str;
              default = {};
              example = { EDITOR = "nvim"; BROWSER = "firefox"; };
              description = "Environment variables";
            };
          };
        };
        default = {};
        description = "ZHF settings";
      };
      
      plugins = mkOption {
        type = types.attrsOf (import ./default.nix { inherit lib pkgs; }).pluginType;
        default = {};
        description = "Plugin configurations";
      };
    };
  };
  
  # Create a ZHF module with pre-configured plugins
  mkZhfModule = { plugins ? {}, settings ? {} }: {
    options.programs.zhf = mkOption {
      type = zhfModuleType;
      default = {};
      description = "ZHF configuration";
    };
    
    config = lib.mkIf config.programs.zhf.enable {
      # Module implementation would go here
      # This would integrate with home-manager or system configuration
    };
  };
  
  # Evaluate ZHF configuration
  evalZhfConfig = config:
    let
      zhfLib = import ./default.nix { inherit lib pkgs; };
    in
    zhfLib.buildConfig config;
  
  # Built-in plugin modules
  builtinPlugins = {
    fzf = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable fzf fuzzy finder";
      };
      
      package = mkOption {
        type = types.package;
        default = pkgs.fzf;
        description = "fzf package to use";
      };
      
      keys = mkOption {
        type = types.listOf types.attrs;
        default = [
          { key = "^T"; action = "fzf-file-widget"; desc = "Find files"; }
          { key = "^R"; action = "fzf-history-widget"; desc = "Search history"; }
          { key = "\\ec"; action = "fzf-cd-widget"; desc = "Change directory"; }
        ];
        description = "Key bindings for fzf";
      };
      
      config = mkOption {
        type = types.attrs;
        default = {
          FZF_DEFAULT_OPTS = "--height 40% --layout=reverse --border";
          FZF_CTRL_T_OPTS = "--preview 'cat {}'";
        };
        description = "fzf configuration options";
      };
    };
    
    starship = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable starship prompt";
      };
      
      package = mkOption {
        type = types.package;
        default = pkgs.starship;
        description = "starship package to use";
      };
      
      lazy = mkOption {
        type = types.bool;
        default = false;
        description = "Load starship lazily (not recommended)";
      };
      
      config = mkOption {
        type = types.attrs;
        default = {};
        description = "Starship configuration";
      };
    };
    
    direnv = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable direnv integration";
      };
      
      package = mkOption {
        type = types.package;
        default = pkgs.direnv;
        description = "direnv package to use";
      };
      
      lazy = mkOption {
        type = types.bool;
        default = false;
        description = "Load direnv lazily";
      };
    };
  };
  
in {
  inherit mkZhfModule evalZhfConfig zhfModuleType builtinPlugins;
}