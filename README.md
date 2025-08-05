# ZHF - Zsh Framework

A declarative, modular Zsh configuration framework inspired by NixOS and nvf, built with Nix flakes.

## Features

- **Declarative Configuration**: Define your entire shell setup in Nix
- **Lazy Loading**: Plugins load asynchronously for fast startup times
- **Dependency Management**: DAG-based plugin ordering with automatic resolution
- **Modular Design**: Mix and match preconfigured modules or create custom ones
- **Performance Monitoring**: Built-in profiling and benchmarking tools
- **Home Manager Integration**: Seamless integration with NixOS/Home Manager
- **Hot Reloading**: Test configurations in development shell

## Quick Start

### 1. Add ZHF to your flake inputs

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    zhf.url = "github:yourusername/zhf";
  };
}
```

### 2. Basic Configuration

```nix
{ inputs, ... }:
{
  imports = [ inputs.zhf.homeManagerModules.default ];
  
  programs.zhf = {
    enable = true;
    
    settings = {
      aliases = {
        ll = "ls -la";
        g = "git";
        gs = "git status";
      };
      
      env = {
        EDITOR = "nvim";
        BROWSER = "firefox";
      };
    };
    
    plugins = {
      fzf.enable = true;
      starship.enable = true;
      zsh-autosuggestions.enable = true;
    };
  };
}
```

### 3. Advanced Configuration

```nix
programs.zhf = {
  enable = true;
  
  settings = {
    zhfRoot = "$HOME/.config/zhf";
    enableStartupProfiling = true;
    
    history = {
      size = 50000;
      save = 50000;
    };
  };
  
  plugins = {
    # Immediate loading for essential tools
    fzf = {
      enable = true;
      lazy = false;
      env = {
        FZF_DEFAULT_OPTS = "--height=40% --layout=reverse --border";
        FZF_DEFAULT_COMMAND = "fd --type f --hidden --follow --exclude .git";
      };
    };
    
    starship = {
      enable = true;
      lazy = false;
    };
    
    # Lazy loading for enhancements
    zsh-autosuggestions = {
      enable = true;
      lazy = true;
      defer = 1;
    };
    
    zsh-syntax-highlighting = {
      enable = true;
      lazy = true;
      defer = 2;
      dependsOn = [ "zsh-autosuggestions" ];
    };
    
    # Custom plugin with complex setup
    dev-tools = {
      enable = true;
      lazy = true;
      defer = 3;
      before = ''
        export PATH="$HOME/.local/bin:$PATH"
      '';
      after = ''
        # Custom functions
        mkcd() { mkdir -p "$1" && cd "$1"; }
        gitignore() { curl -sL "https://www.toptal.com/developers/gitignore/api/$1"; }
      '';
      keys = [
        { key = "^G^S"; action = "git status"; desc = "Quick git status"; }
      ];
    };
  };
};
```

## Development

### Setting up the development environment

```bash
# Clone the repository
git clone https://github.com/yourusername/zhf
cd zhf

# Enter development shell
nix develop

# Available commands in dev shell:
zhf-test      # Test configuration
zhf-build     # Build configuration  
zhf-reload    # Reload zsh with new config
```

### Testing configurations

```bash
# Test basic example
nix eval .#examples.basic --json | jq

# Test advanced example  
nix eval .#examples.advanced --json | jq

# Build and test in isolation
nix build .#examples.basic
```

### Creating custom plugins

```nix
plugins = {
  my-custom-plugin = {
    enable = true;
    lazy = true;
    defer = 2;
    
    before = ''
      # Setup code before plugin loads
      export MY_PLUGIN_VAR="value"
    '';
    
    after = ''
      # Code after plugin loads
      my_function() {
        echo "Custom function from my plugin"
      }
    '';
    
    keys = [
      { 
        key = "^X^M"; 
        action = "my_function"; 
        desc = "Execute my custom function"; 
      }
    ];
    
    dependsOn = [ "fzf" "starship" ];
  };
}
```

## Plugin System

### Built-in Plugins

- **fzf**: Fuzzy finder with file/history/directory widgets
- **starship**: Cross-shell prompt with Git integration
- **direnv**: Per-directory environment management
- **zsh-autosuggestions**: Fish-like autosuggestions
- **zsh-syntax-highlighting**: Syntax highlighting for commands
- **zsh-completions**: Additional completion definitions

### Plugin Options

Every plugin supports these options:

```nix
plugin-name = {
  enable = true;              # Enable the plugin
  lazy = true;                # Load lazily (default: true)
  defer = 2;                  # Defer loading by N seconds
  dependsOn = [ "other" ];    # Plugin dependencies
  
  before = "# Setup code";    # Code to run before loading
  after = "# Config code";    # Code to run after loading
  
  env = {                     # Environment variables
    VAR_NAME = "value";
  };
  
  keys = [                    # Key bindings
    {
      key = "^T";
      action = "some-command";
      desc = "Description";
    }
  ];
  
  package = pkgs.some-pkg;    # Override default package
  config = { };               # Plugin-specific config
};
```

### Loading Strategies

1. **Immediate**: `lazy = false` - Load during shell initialization
2. **Deferred**: `defer = N` - Load after N seconds using zsh-defer
3. **Conditional**: `triggers = ["command:git"]` - Load when command is used
4. **Event-based**: `triggers = ["event:chpwd"]` - Load on shell events

## Performance

ZHF is designed for performance:

- **Lazy Loading**: Non-essential plugins load after shell is ready
- **Dependency Resolution**: Optimal loading order via DAG sorting
- **Caching**: Completion cache and plugin state persistence
- **Profiling**: Built-in tools to measure and optimize startup time

### Performance Monitoring

```bash
# Profile startup time
zhf-profile

# Benchmark average startup time
zhf-benchmark 10

# Show plugin load times
zhf-timing
```

## Architecture

```
zhf/
├── flake.nix              # Main flake definition
├── lib/                   # Core library functions
│   ├── default.nix        # Main library exports
│   ├── dag.nix           # Dependency resolution
│   ├── lazy-loading.nix   # Lazy loading system
│   └── module-system.nix  # Module type definitions
├── modules/               # Integration modules
│   └── home-manager.nix   # Home Manager module
├── examples/              # Example configurations
│   ├── basic.nix          # Simple setup
│   └── advanced.nix       # Complex configuration
└── README.md              # This file
```

## Comparison with other frameworks

| Feature | ZHF | Oh My Zsh | Prezto | Zinit |
|---------|-----|-----------|--------|-------|
| Declarative Config | ✅ | ❌ | ❌ | ❌ |
| Dependency Management | ✅ | ❌ | ✅ | ✅ |
| Lazy Loading | ✅ | ❌ | ❌ | ✅ |
| Reproducible | ✅ | ❌ | ❌ | ❌ |
| Performance Monitoring | ✅ | ❌ | ❌ | ✅ |
| Plugin Ecosystem | Growing | Huge | Large | Large |

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Submit a pull request

### Adding new built-in plugins

1. Add plugin definition to `modules/home-manager.nix`:

```nix
my-plugin = {
  package = pkgs.my-plugin;
  lazy = true;
  defer = 1;
  after = ''
    source "${pkgs.my-plugin}/share/my-plugin.zsh"
  '';
  env = {
    MY_PLUGIN_CONFIG = "default-value";
  };
};
```

2. Add plugin options to the module system
3. Update examples and documentation
4. Add tests for the new plugin

### Plugin Development Guidelines

- **Performance First**: Use lazy loading for non-essential plugins
- **Minimal Dependencies**: Avoid complex dependency chains
- **Error Handling**: Gracefully handle missing dependencies
- **Documentation**: Include clear descriptions and examples
- **Testing**: Ensure plugins work in isolation and with others

## Troubleshooting

### Common Issues

**Slow startup time:**
```bash
# Enable profiling to identify bottlenecks
programs.zhf.settings.enableStartupProfiling = true;

# Check which plugins are loading immediately
zhf-timing
```

**Plugin conflicts:**
```bash
# Check dependency resolution
nix eval .#lib.validateDAG --json | jq
```

**Missing completions:**
```bash
# Rebuild completion cache
rm -rf ~/.zhf/cache/zcompdump*
exec zsh
```

### Debug Mode

Enable debug output:

```nix
programs.zhf.settings.env.ZHF_DEBUG = "1";
```

### Performance Tuning

1. **Profile your setup:**
   ```bash
   ZHF_PROFILE=1 zsh -i -c 'exit'
   ```

2. **Optimize plugin loading:**
   - Move non-essential plugins to lazy loading
   - Increase defer times for less critical plugins
   - Remove unused plugins

3. **Cache optimization:**
   ```nix
   settings.completion.cache = true;
   settings.zhfRoot = "/tmp/zhf-cache";  # Use tmpfs for speed
   ```

## Migration Guides

### From Oh My Zsh

```nix
# Instead of oh-my-zsh themes
plugins.starship.enable = true;

# Instead of oh-my-zsh plugins
plugins = {
  # oh-my-zsh: git plugin
  fzf.enable = true;  # Better git integration with fzf
  
  # oh-my-zsh: autosuggestions plugin  
  zsh-autosuggestions.enable = true;
  
  # oh-my-zsh: syntax-highlighting plugin
  zsh-syntax-highlighting.enable = true;
};

# Convert aliases
settings.aliases = {
  # Your existing oh-my-zsh aliases
  gst = "git status";
  gco = "git checkout";
  # ... etc
};
```

### From Prezto

```nix
# Prezto modules → ZHF plugins
programs.zhf.plugins = {
  # prezto: editor module
  # Built into ZHF core settings
  
  # prezto: git module
  fzf.enable = true;  # Better git integration
  
  # prezto: syntax-highlighting module
  zsh-syntax-highlighting.enable = true;
  
  # prezto: autosuggestions module
  zsh-autosuggestions.enable = true;
};
```

### From Zinit

```nix
# Zinit turbo mode → ZHF lazy loading
plugins.my-plugin = {
  enable = true;
  lazy = true;        # Equivalent to zinit ice wait
  defer = 1;          # Equivalent to zinit ice wait"1"
};

# Zinit load vs light → ZHF package management
plugins.my-plugin.package = pkgs.my-plugin;  # Nix handles the package
```

## Roadmap

### v1.0 (Current)
- ✅ Basic plugin system
- ✅ Lazy loading with zsh-defer
- ✅ DAG-based dependency resolution
- ✅ Home Manager integration
- ✅ Built-in plugin library

### v1.1 (Planned)
- 🔄 Plugin hot-reloading in dev shell
- 🔄 Advanced conditional loading (file-based triggers)
- 🔄 Plugin marketplace/registry
- 🔄 Migration tools from other frameworks
- 🔄 Shell completion for zhf commands

### v1.2 (Future)
- 📋 GUI configuration editor
- 📋 Plugin dependency visualization
- 📋 Automated performance optimization
- 📋 Integration with other shells (fish, bash)
- 📋 Cloud sync for configurations

## License

MIT License - see [LICENSE](LICENSE) for details.

## Acknowledgments

- **nvf**: Inspiration for the declarative configuration approach
- **NixOS**: Foundation for the module and packaging system
- **zsh-defer**: Lazy loading implementation
- **Home Manager**: Integration patterns and user experience
- **Oh My Zsh/Prezto/Zinit**: Plugin ecosystem and feature inspiration

## Support

<!-- - 📖 [Documentation](https://zhf.dev/docs) -->
<!-- - 💬 [Discord Community](https://discord.gg/zhf) -->
- 🐛 [Issue Tracker](https://github.com/yourusername/zhf/issues)
<!-- - 📧 [Mailing List](https://groups.google.com/g/zhf-users) -->

---

**ZHF** - *Declarative Zsh configuration that just works* ⚡