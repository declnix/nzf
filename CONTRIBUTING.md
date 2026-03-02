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
