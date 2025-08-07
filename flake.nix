{
  outputs =
    { flakelight, nixpkgs, ... }@inputs:
    flakelight ./. {
      apps = {
        sandbox = { writeShellScriptBin, ...}: let
          script = writeShellScriptBin "sandbox" ''
          nixos-rebuild build-vm --flake ".#myhost" && result/bin/run-*-vm -display none -serial mon:stdio
        '';
        in "${script}/bin/sandbox"; 
      };

      homeModule = ./modules/home-manager.nix;

      nixosConfigurations = {
        myhost = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
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
                ];

                home.stateVersion = "25.05";
                programs.nzf.enable = true;
                programs.zsh.enable = true;
              };
            }

            inputs.home-manager.nixosModules.home-manager

          ];
        };
      };

      devShell = pkgs: {
        packages = with pkgs; [
          nixfmt-rfc-style
          lefthook
        ];

        shellHook = ''
          # Run lefthook install only once per shell session
          if [[ -d .git &&  -f .lefthook.yml && -z "$_LEFTHOOK_INSTALLED" ]]; then
            export _LEFTHOOK_INSTALLED=1
            lefthook install
          fi
        '';
      };
    };

  inputs = {
    flakelight.url = "github:nix-community/flakelight";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
