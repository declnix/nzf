{ outputs, inputs, config, ... }: {
  system = "x86_64-linux";
  specialArgs = { inherit inputs; };
  modules = [
    config.propagationModule
    ({ pkgs, flake, ... }: {
      boot.loader.grub.enable = false;
      boot.loader.systemd-boot.enable = true;
      users.defaultUserShell = pkgs.zsh;
      users.users.root.initialHashedPassword = "";
      networking.hostName = "vm";
      environment.systemPackages = with pkgs; [ zsh ];
      programs.zsh.enable = true;
      nix.settings.experimental-features = [ "nix-command" "flakes" ];
      home-manager.users.root = {
        imports = [
          ./../../examples/example.nix
          outputs.homeModules.default
        ];
        home.stateVersion = "25.05";
      };
    })
    inputs.home-manager.nixosModules.home-manager
  ];
}
