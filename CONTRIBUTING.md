## Commit Convention

### Format

```
type(scope): short imperative message
```

---

### Scope Rules

* `scope = core` → framework infrastructure (flake, outputs, homeModule, flakelightModules)
* `scope = <plugin-name>` → specific plugin (e.g., `zsh-autosuggestions`)
* `scope = test` → test VM configuration

---

### Allowed Types

* `feat`
* `fix`
* `refactor`
* `chore`
* `style`
* `docs`
* `ci`

---

### Examples

```
feat(core): add plugin defer support
feat(zsh-autosuggestions): add compatibility alias
fix(core): correct plugin ordering
refactor(test): simplify VM configuration
docs(core): update README
```

---

## Plugin File Structure

In plugin modules, use nested attribute sets and order entries as follows:

1. Plugin entry (`plugins.<name>`)
2. Feature flags (`zsh-defer.enable`, etc.)
3. Other dependencies outside the nested block (`home.packages`, etc.)

```nix
config = mkIf cfg.enable {
  programs.nzf = {
    plugins.example = entryAfter [ "zsh-defer" ] (
      defer (plugin pkgs.example)
    );
    zsh-defer.enable = mkDefault true;
  };
  home.packages = [ pkgs.dependency ];
};
```
