{
  description = "Declarative zsh plugin manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flakelight.url = "github:nix-community/flakelight";
    home-manager.url = "github:nix-community/home-manager";
    import-tree.url = "github:vic/import-tree";
  };

  outputs = {flakelight, ...} @ inputs:
    flakelight ./. {
      inherit inputs;

      lib = import ./lib {inherit (inputs.nixpkgs) lib;};

      homeModule = {lib, config, ...}: {
        imports = [
          (inputs.import-tree ./homeModule/plugins)
          ./homeModule
        ];
      };

      devShell = {pkgs, ...}: pkgs.mkShell {packages = [pkgs.nixfmt];};

      nixosConfigurations.nzf-test = {
        system = "x86_64-linux";
        modules = [inputs.home-manager.nixosModules.home-manager ./tests/vm.nix];
        specialArgs.inputs = inputs // {nzf = inputs.self;};
      };
    };
}
