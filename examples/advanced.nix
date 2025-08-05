{ lib, zhfLib }:

{
  # Advanced ZHF configuration with custom plugins and complex setup
  programs.zhf = {
    enable = true;
    
    settings = {
      zhfRoot = "$HOME/.config/zhf";
      enableStartupProfiling = true;  # Enable for performance monitoring
      
      history = {
        enable = true;
        size = 100000;
        save = 100000;
      };
      
      completion = {
        enable = true;
      };
      
      navigation = {
        enable = true;
      };
      
      # Extensive aliases for development workflow
      aliases = {
        # Git workflow
        g = "git";
        gs = "git status";
        gss = "git status --short";
        ga = "git add";
        gaa = "git add --all";
        gc = "git commit";
        gcm = "git commit -m";
        gca = "git commit --amend";
        gco = "git checkout";
        gcb = "git checkout -b";
        gb = "git branch";
        gba = "git branch -a";
        gbd = "git branch -d";
        gp = "git push";
        gpu = "git push -u origin";
        gl = "git log --oneline";
        gll = "git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'";
        gd = "git diff";
        gdc = "git diff --cached";
        gst = "git stash";
        gstp = "git stash pop";
        gm = "git merge";
        gr = "git rebase";
        gri = "git rebase -i";
        
        # Docker shortcuts
        d = "docker";
        dc = "docker-compose";
        dcu = "docker-compose up";
        dcd = "docker-compose down";
        dcb = "docker-compose build";
        dps = "docker ps";
        di = "docker images";
        
        # Kubernetes shortcuts
        k = "kubectl";
        kgp = "kubectl get pods";
        kgs = "kubectl get services";
        kgd = "kubectl get deployments";
        kdp = "kubectl describe pod";
        kds = "kubectl describe service";
        kdd = "kubectl describe deployment";
        
        # System shortcuts
        ll = "ls -la";
        la = "ls -A";
        l = "ls -CF";
        lt = "ls -lt";
        lh = "ls -lah";
        tree = "tree -C";
        
        # Network tools
        myip = "curl -s https://ipinfo.io/ip";
        localip = "ip route get 1.1.1.1 | grep -oP 'src \\K\\S+'";
        ports = "netstat -tulanp";
        
        # System monitoring
        htop = "htop -C";
        df = "df -h";
        du = "du -h";
        free = "free -h";
        ps = "ps aux";
        
        # Development tools
        serve = "python3 -m http.server 8000";
        json = "python3 -m json.tool";
        urlencode = "python3 -c 'import sys, urllib.parse; print(urllib.parse.quote(sys.argv[1]))'";
        urldecode = "python3 -c 'import sys, urllib.parse; print(urllib.parse.unquote(sys.argv[1]))'";
      };
      
      # Development environment variables
      env = {
        EDITOR = "nvim";
        VISUAL = "nvim";
        BROWSER = "firefox";
        PAGER = "less";
        LESS = "-R --mouse";
        MANPAGER = "nvim +Man!";
        
        # Development tools
        DOCKER_BUILDKIT = "1";
        COMPOSE_DOCKER_CLI_BUILD = "1";
        
        # Language-specific
        GOPATH = "$HOME/go";
        GOBIN = "$HOME/go/bin";
        CARGO_HOME = "$HOME/.cargo";
        RUSTUP_HOME = "$HOME/.rustup";
        
        # Tool configuration
        FZF_DEFAULT_OPTS = "--height=40% --layout=reverse --border --margin=1 --padding=1";
        BAT_THEME = "TwoDark";
        RIPGREP_CONFIG_PATH = "$HOME/.config/ripgrep/config";
      };
    };
    
    plugins = {
      # Core functionality - load immediately
      fzf = {
        enable = true;
        lazy = false;
        env = {
          FZF_DEFAULT_COMMAND = "fd --type f --strip-cwd-prefix --hidden --follow --exclude .git";
          FZF_CTRL_T_COMMAND = "$FZF_DEFAULT_COMMAND";
          FZF_ALT_C_COMMAND = "fd --type d --strip-cwd-prefix --hidden --follow --exclude .git";
          FZF_DEFAULT_OPTS = "--height=40% --layout=reverse --border --margin=1 --padding=1 --preview-window=right:60%";
          FZF_CTRL_T_OPTS = "--preview 'bat --color=always --line-range=:100 {}'";
          FZF_ALT_C_OPTS = "--preview 'tree -C {} | head -100'";
        };
        keys = [
          { key = "^T"; action = "fzf-file-widget"; desc = "Find files"; }
          { key = "^R"; action = "fzf-history-widget"; desc = "Search history"; }
          { key = "\\ec"; action = "fzf-cd-widget"; desc = "Change directory"; }
        ];
      };
      
      starship = {
        enable = true;
        lazy = false;
      };
      
      direnv = {
        enable = true;
        lazy = false;
      };
      
      # Enhancement plugins - lazy loaded
      zsh-autosuggestions = {
        enable = true;
        lazy = true;
        defer = 1;
        after = ''
          ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#666666,underline"
          ZSH_AUTOSUGGEST_STRATEGY=(history completion)
          ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
        '';
      };
      
      zsh-syntax-highlighting = {
        enable = true;
        lazy = true;
        defer = 2;
        dependsOn = [ "zsh-autosuggestions" ];
        after = ''
          # Custom syntax highlighting colors
          ZSH_HIGHLIGHT_STYLES[command]='fg=blue,bold'
          ZSH_HIGHLIGHT_STYLES[alias]='fg=magenta,bold'
          ZSH_HIGHLIGHT_STYLES[builtin]='fg=cyan,bold'
          ZSH_HIGHLIGHT_STYLES[function]='fg=green,bold'
          ZSH_HIGHLIGHT_STYLES[path]='fg=white,underline'
          ZSH_HIGHLIGHT_STYLES[globbing]='fg=yellow'
        '';
      };
      
      zsh-completions = {
        enable = true;
        lazy = true;
        defer = 1;
        before = ''
          # Add completions to fpath before compinit
          fpath+="$ZHF_ROOT/completions"
          mkdir -p "$ZHF_ROOT/completions"
        '';
      };
      
      # Custom development plugin
      dev-tools = {
        enable = true;
        lazy = true;
        defer = 3;
        before = ''
          # Set up development environment
          export PATH="$HOME/.local/bin:$PATH"
          export PATH="$GOBIN:$PATH"
          export PATH="$HOME/.cargo/bin:$PATH"
          export PATH="$HOME/.npm-global/bin:$PATH"
        '';
        after = ''
          # Development helper functions
          gitignore() {
            curl -sL "https://www.toptal.com/developers/gitignore/api/$1"
          }
          
          mkcd() {
            mkdir -p "$1" && cd "$1"
          }
          
          extract() {
            if [ -f "$1" ]; then
              case "$1" in
                *.tar.bz2)   tar xjf "$1"     ;;
                *.tar.gz)    tar xzf "$1"     ;;
                *.bz2)       bunzip2 "$1"     ;;
                *.rar)       unrar x "$1"     ;;
                *.gz)        gunzip "$1"      ;;
                *.tar)       tar xf "$1"      ;;
                *.tbz2)      tar xjf "$1"     ;;
                *.tgz)       tar xzf "$1"     ;;
                *.zip)       unzip "$1"       ;;
                *.Z)         uncompress "$1"  ;;
                *.7z)        7z x "$1"        ;;
                *)           echo "'$1' cannot be extracted via extract()" ;;
              esac
            else
              echo "'$1' is not a valid file"
            fi
          }
          
          # Project shortcuts
          work() {
            cd "$HOME/work/$1" 2>/dev/null || cd "$HOME/projects/$1" 2>/dev/null || echo "Project not found"
          }
          
          # Quick edit configs
          zshconfig() { $EDITOR "$HOME/.zshrc" }
          zhfconfig() { $EDITOR "$HOME/.config/zhf" }
          
          # Git helpers
          gclean() {
            git branch --merged | grep -v "\\*\\|main\\|master\\|develop" | xargs -n 1 git branch -d
          }
          
          gsync() {
            git fetch origin
            git rebase origin/$(git branch --show-current)
          }
        '';
        keys = [
          { key = "^G^S"; action = "gsync"; desc = "Git sync with remote"; }
          { key = "^G^C"; action = "gclean"; desc = "Clean merged branches"; }
        ];
      };
      
      # Performance monitoring plugin
      perf-monitor = {
        enable = true;
        lazy = true;
        defer = 5;
        after = ''
          # Shell performance monitoring
          zhf-benchmark() {
            local iterations=''${1:-10}
            local total=0
            
            for i in {1..$iterations}; do
              local start=$(($(date +%s%3N)))
              zsh -i -c 'exit'
              local end=$(($(date +%s%3N)))
              local time=$((end - start))
              total=$((total + time))
              echo "Run $i: ''${time}ms"
            done
            
            echo "Average startup time: $((total / iterations))ms"
          }
          
          zhf-profile() {
            ZHF_PROFILE=1 zsh -i -c 'exit'
          }
        '';
      };
    };
  };
}