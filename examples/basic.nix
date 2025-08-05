{ lib, zhfLib }:

{
  # Basic ZHF configuration example
  programs.zhf = {
    enable = true;
    
    settings = {
      # Core settings
      zhfRoot = "$HOME/.config/zhf";
      enableStartupProfiling = false;
      
      # History configuration
      history = {
        enable = true;
        size = 50000;
        save = 50000;
      };
      
      # Completion settings
      completion = {
        enable = true;
      };
      
      # Navigation helpers
      navigation = {
        enable = true;
      };
      
      # Custom aliases
      aliases = {
        # Git shortcuts
        g = "git";
        gs = "git status";
        ga = "git add";
        gc = "git commit";
        gp = "git push";
        gl = "git log --oneline";
        
        # Directory navigation
        ll = "ls -la";
        la = "ls -A";
        l = "ls -CF";
        
        # System shortcuts
        grep = "grep --color=auto";
        df = "df -h";
        du = "du -h";
        free = "free -h";
      };
      
      # Environment variables
      env = {
        EDITOR = "nvim";
        BROWSER = "firefox";
        PAGER = "less";
        LESS = "-R";
      };
    };
    
    # Plugin configuration
    plugins = {
      # Essential plugins enabled by default
      fzf = {
        enable = true;
        lazy = false;  # Load immediately for better UX
        env = {
          FZF_DEFAULT_OPTS = "--height 40% --layout=reverse --border --preview-window=right:60%";
          FZF_DEFAULT_COMMAND = "find . -type f -not -path '*/\\.git/*' 2>/dev/null";
          FZF_CTRL_T_COMMAND = "$FZF_DEFAULT_COMMAND";
        };
      };
      
      starship = {
        enable = true;
        lazy = false;  # Prompt should load immediately
      };
      
      # Lazy-loaded enhancement plugins
      zsh-autosuggestions = {
        enable = true;
        lazy = true;
        defer = 1;  # Load after 1 second
      };
      
      zsh-syntax-highlighting = {
        enable = true;
        lazy = true;
        defer = 2;  # Load after autosuggestions
        dependsOn = [ "zsh-autosuggestions" ];
      };
      
      zsh-completions = {
        enable = true;
        lazy = true;
        defer = 1;
      };
      
      # Optional: direnv for project-specific environments
      direnv = {
        enable = false;  # Disabled by default, enable if needed
        lazy = false;
      };
    };
  };
}