{ pkgs, ... }:

{
  config = ''
    source ${pkgs.zsh-defer}/share/zsh-defer/zsh-defer.plugin.zsh
  '';

  defer = false;

  after = [ ];
}
