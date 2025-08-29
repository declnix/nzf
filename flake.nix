{
  inputs = {
    flakelight.url = "github:nix-community/flakelight";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      flakelight,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
    in
    flakelight ./. (rec {
      nixosConfigurations = {
        vm = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            (
              { pkgs, ... }:
              {
                boot.loader.grub.enable = false;
                boot.loader.systemd-boot.enable = true;

                users.defaultUserShell = pkgs.zsh;
                users.users.root.initialHashedPassword = "";
                networking.hostName = "vm";

                environment.systemPackages = with pkgs; [
                  zsh
                ];

                programs.zsh.enable = true;

                nix.settings.experimental-features = [
                  "nix-command"
                  "flakes"
                ];

                home-manager.users.root = {
                  imports = [
                    ./example.nix
                    homeModule.module
                  ];
                  home.stateVersion = "25.05";
                };
              }
            )
            home-manager.nixosModules.home-manager
          ];
        };
      };

      homeModule = {
        module = ./flake/modules/home-manager.nix;
      };

      devShell = pkgs: {
        packages = with pkgs; [
          nixfmt-rfc-style
          lefthook
          gnumake
        ];

        shellHook = ''
          if [[ -d .git && -f .lefthook.yml && -z "$_LEFTHOOK_INSTALLED" ]]; then
            export _LEFTHOOK_INSTALLED=1
            lefthook install
          fi
        '';
      };
    });
}
