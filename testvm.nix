{ inputs, type, ... }:
{
  services.getty.autologinUser = "demo";
  users.users.root.initialPassword = "root"; # if needed
  environment.loginShellInit = ''
    trap 'sudo shutdown now' EXIT
  '';
  system.stateVersion = "25.05";

  users.users.demo = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # allows sudo
    password = "demo"; # or use hashedPassword
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.demo = {
    imports = [
      ./modules/home-manager.nix
      ./examples/${type}.nix
    ];
    home.stateVersion = "25.05";
  };
}
