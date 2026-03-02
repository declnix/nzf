{ pkgs, flake, ... }:
{
  virtualisation.vmVariant.virtualisation.graphics = false;
  system.stateVersion = "25.05";

  programs.zsh.enable = true;

  users.users.test = {
    isNormalUser = true;
    password = "test";
    shell = pkgs.zsh;
  };

  services.getty.autologinUser = "test";

  security.sudo.extraRules = [{
    users = [ "test" ];
    commands = [{
      command = "/run/current-system/sw/bin/poweroff";
      options = [ "NOPASSWD" ];
    }];
  }];

  environment.etc."motd".text = ''
    ══════════════════════════════════════
    nzf test VM

    Exit: 'q' or Ctrl+A X
    ══════════════════════════════════════
  '';

  home-manager.extraSpecialArgs = { inherit (flake) inputs; };

  home-manager.users.test = {
    imports = [ ../homeModule ];

    programs.nzf = {
      enable = true;
      autosuggestion.enable = true;
    };

    programs.zsh.shellAliases.q = "sudo poweroff";

    home.stateVersion = "25.11";
  };
}
