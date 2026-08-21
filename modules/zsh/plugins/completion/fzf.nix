{
  nzf.modules = [
    ({ config, lib, pkgs, ... }:
    let
      inherit (lib) mkEnableOption mkIf;
      cfg = config.nzf.zsh.completion.integrations.fzf;
    in
    {
      options.nzf.zsh.completion.integrations.fzf.enable = mkEnableOption "fzf completion integration";

      config = mkIf (config.nzf.zsh.enable && cfg.enable) {
        nzf.zsh.extraPlugins.nzf-fzf-completion = {
          after = [
            "nzf-completion"
            "nzf-zsh-defer"
          ];
          defer = true;
          source = "${pkgs.fetchFromGitHub {
            owner = "Aloxaf";
            repo = "fzf-tab";
            rev = "e394092c17277c84cb3d234917c4ac1073102ba6";
            sha256 = "sha256-WlmWLKHrLeptc5rqlHbKvthD73it9ij7IDT9QxN4jCc=";
          }}/fzf-tab.plugin.zsh";
          config = "enable-fzf-tab";
        };
      };
    })
  ];
}
