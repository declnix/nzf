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
    { flakelight, nixpkgs, ... }@inputs:
    let
      exampleFiles = builtins.readDir ./examples;
      exampleNames = builtins.attrNames (
        nixpkgs.lib.filterAttrs (
          name: type: type == "regular" && nixpkgs.lib.hasSuffix ".nix" name
        ) exampleFiles
      );

      configNames = map (name: nixpkgs.lib.removeSuffix ".nix" name) exampleNames;

      # Single base system configuration
      baseSystem =
        type:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs type; };
          modules = [
            ./testvm.nix
            inputs.home-manager.nixosModules.home-manager
          ];
        };

      genConfigs =
        configs:
        builtins.listToAttrs (
          map (config: {
            name = config;
            value = baseSystem config;
          }) configs
        );
    in
    flakelight ./. {
      nixosConfigurations = genConfigs configNames;

      devShell = pkgs: {
        packages = with pkgs; [
          nixfmt-rfc-style
          lefthook
        ];

        shellHook = ''
          if [[ -d .git && -f .lefthook.yml && -z "$_LEFTHOOK_INSTALLED" ]]; then
            export _LEFTHOOK_INSTALLED=1
            lefthook install
          fi
        '';
      };

      homeModule = ./modules/home-manager.nix;
    };
}
