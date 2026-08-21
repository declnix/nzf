{ config, inputs, lib, ... }:

{
  perSystem =
    { pkgs, ... }:
    let
      demo = inputs.self.lib.zshConfiguration {
        inherit pkgs;
        modules = [
          {
            nzf.zsh = {
              enable = true;
              completion.enable = true;
              completion.integrations.fzf.enable = true;
              history.enable = true;
              history.integrations.fzf.enable = true;
              autosuggestions.enable = true;
              viMode.enable = true;
              highlighting.enable = true;
              highlighting.integrations.patina.enable = true;
              plugins.git.enable = true;
              initConfig = ''PROMPT="%B%F{magenta}#%f%b "'';
            };
          }
        ];
      };
    in
    {
      packages.default = demo.wrapper;

      apps.default = {
        type = "app";
        program = "${demo.wrapper}/bin/zsh";
      };

      checks.render = pkgs.runCommand "nzf-render" { } ''
        rc=${demo.rcFile}
        grep -q 'compinit' "$rc"
        grep -q 'fzf-tab.plugin.zsh' "$rc"
        grep -q 'zsh-fzf-history-search.plugin.zsh' "$rc"
        grep -q 'zsh-autosuggestions.zsh' "$rc"
        grep -q 'zsh-vi-mode.plugin.zsh' "$rc"
        grep -q 'zsh-patina activate' "$rc"
        grep -q 'lib/git.zsh' "$rc"
        grep -q 'plugins/git/git.plugin.zsh' "$rc"
        grep -q 'zsh-defer' "$rc"
        grep -q '_nzf_defer_nzf_fzf_completion' "$rc"
        grep -q '_nzf_defer_nzf_fzf_history' "$rc"
        touch $out
      '';

      checks.smoke = pkgs.runCommand "nzf-smoke" { nativeBuildInputs = [ pkgs.zsh ]; } ''
        export HOME="$(mktemp -d)"
        output="$(${demo.wrapper}/bin/zsh -i -c 'print -- NZF_OK' 2>/dev/null)"
        test "$output" = NZF_OK
        touch $out
      '';
    };
}
