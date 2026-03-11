{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf optional;
  nzf = import ../../lib { inherit lib; };
  inherit (nzf) entryBefore;
  cfg = config.programs.nzf.zsh-fzf-tab;
  autosuggestion = config.programs.nzf.autosuggestion;
  autosuggestions = config.programs.nzf.zsh-autosuggestions;
  src = pkgs.fetchFromGitHub {
    owner = "Aloxaf";
    repo = "fzf-tab";
    rev = "c7fb028ec0bbc1056c51508602dbd61b0f475ac3";
    hash = "sha256-Qv8zAiMtrr67CbLRrFjGaPzFZcOiMVEFLg1Z+N6VMhg=";
  };
in
{
  options.programs.nzf.zsh-fzf-tab.enable = mkEnableOption "zsh-fzf-tab";

  config = mkIf cfg.enable {
    home.packages = [ pkgs.fzf ];
    programs.nzf.plugins.zsh-fzf-tab = entryBefore (
      optional (autosuggestion.enable || autosuggestions.enable) "zsh-autosuggestions"
    ) "source ${src}/fzf-tab.plugin.zsh";
  };
}
