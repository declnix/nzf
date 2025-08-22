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
        sandbox = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            (
              { pkgs, ... }:
              {
                boot.loader.grub.enable = false;
                boot.loader.systemd-boot.enable = true;

                users.users.root.initialHashedPassword = "";
                networking.hostName = "sandbox";

                nix.settings.experimental-features = [
                  "nix-command"
                  "flakes"
                ];

                home-manager.users.root = {
                  imports = [
                    (
                      { pkgs, ... }:
                      {
                        programs.nzf = {
                          plugins = {
                            zsh-defer = rec {
                              plugin = pkgs.zsh-defer;

                              config = with pkgs; ''
                                source ${plugin}/share/zsh-defer/zsh-defer.plugin.zsh
                              '';

                              after = [ ];
                            };

                            zsh-fzf-tab = rec {
                              plugin = pkgs.zsh-fzf-tab;

                              config = with pkgs; ''
                                source ${plugin}/share/fzf-tab/fzf-tab.plugin.zsh
                              '';

                              after = [ ];
                            };

                          };
                          enable = true;
                        };
                      }
                    )
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
        module = ./home-manager/module.nix;
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
