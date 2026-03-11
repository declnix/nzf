{
  pkgs,
  inputs,
  lib,
  modulesPath,
  ...
}:
{
  imports = [ (modulesPath + "/virtualisation/qemu-vm.nix") ];

  virtualisation.graphics = false;
  system.stateVersion = "25.05";

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  boot.loader.grub.device = lib.mkDefault "/dev/sda";

  programs.zsh.enable = true;

  users.users.test = {
    isNormalUser = true;
    password = "test";
    shell = pkgs.zsh;
  };

  services.getty.autologinUser = "test";

  security.sudo.extraRules = [
    {
      users = [ "test" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/poweroff";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  environment.etc."motd".text = ''
    ══════════════════════════════════════
    nzf test VM

    Exit: 'q' or Ctrl+A X
    ══════════════════════════════════════
  '';

  home-manager.users.test =
    { ... }:
    {
      imports = [ inputs.nzf.homeModules.default ];

      programs.nzf = {
        enable = true;
        zsh-defer.enable = true;
        zsh-fzf-tab.enable = true;
        zsh-fzf-history-search.enable = true;
        zsh-autosuggestions.enable = true;
        zsh-syntax-highlighting.enable = true;
        oh-my-zsh.plugins = [ "git" ];

        plugins.my-config = inputs.nzf.lib.entryAfter [ "zsh-autosuggestions" ] ''
          bindkey '^ ' autosuggest-accept
        '';
      };

      programs.zsh.shellAliases.q = "sudo poweroff";
      home.stateVersion = "25.11";
    };
}
