# nzf - An Extensible Zsh Configuration Wrapper for Nix 👋

[![NixOS Unstable](https://img.shields.io/badge/NixOS-unstable-blue.svg?style=flat-square)](https://nixos.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](https://opensource.org/licenses/MIT)

`nzf` is a personal Zsh configuration generator for Nix-based environments, primarily designed to bring the concept of declarative plugin blocks that can be loaded in a specific order or deferred. It offers the ability to declaratively manage your Zsh plugins, ensuring they are loaded in the correct order or deferred.

## ⚠️ Disclaimer

**This project is under heavy development and should be considered experimental. Breaking changes may be introduced at any time without prior notice.**

## ✨ Features

- **Declarative Plugin Management:** Define your Zsh plugins as a set of attributes in your Nix configuration.
- **Dependency Resolution:** `nzf` automatically sorts your plugins based on their dependencies, ensuring they are loaded in the correct order.
- **NixOS and Home Manager Compatible:** `nzf` can be used as a module in both NixOS and Home Manager configurations.
- **Simple and Extensible:** The core logic is simple and can be easily extended to support more complex configurations.

## 🚀 Usage

To use `nzf` in your Nix flake, add it as an input and import the module in your NixOS or Home Manager configuration.

```nix
{ pkgs, lib, ... }:
{
  programs.nzf = {
    plugins = with pkgs; {
      zsh-fzf-tab = rec {
        config = ''
          source ${zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
        '';

        defer = true;

        extraPackages = [ fzf ];
      };

      zsh-vi-mode = rec {
        config = ''
          source ${zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
        '';
      };

      zsh-fzf-history-search = {
        config = ''
          source ${zsh-fzf-history-search}/share/zsh-fzf-history-search/zsh-fzf-history-search.plugin.zsh
        '';
        defer = true;
        extraPackages = [ fzf ];
        # Ensure zsh-fzf-history-search loads after zsh-vi-mode to prevent keybinding conflicts.
        after = [ "zsh-vi-mode" ];
      };

    };
    enable = true;
  };
}
```

## ⚙️ Plugin Configuration

Each plugin is defined as an attribute set with the following attributes:

- `config`: A string containing the Zsh script to be loaded for the plugin.
- `after` (optional, default: `[]`): A list of plugin names that this plugin depends on. `nzf` will ensure that the dependencies are loaded before this plugin.
- `extraPackages` (optional, default: `[]`): A list of extra packages required by the plugin.
- `defer` (optional, default: `false`): A boolean value to defer the loading of the plugin. When set to `true`, the plugin will be loaded using `zsh-defer`, and the `zsh-defer` plugin will be automatically added as a dependency.

## 🔧 Development

To set up a development environment, you can use the provided `devShell`.

```bash
nix develop
```

This will drop you into a shell with the necessary tools to work on `nzf`.

## ✨ Inspiration

`nzf` draws inspiration from [nvf](https://github.com/NotAShelf/nvf), a similar project for Neovim.

## 📜 License

`nzf` is licensed under the [MIT License](https://opensource.org/licenses/MIT).