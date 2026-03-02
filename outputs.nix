inputs: {
  inherit inputs;

  imports = [ ./flakelightModules/plugins.nix ];

  nixDir = ./.;

  devShells.default = pkgs: pkgs.mkShell { packages = [ pkgs.nixfmt-rfc-style ]; };

  nixosConfigurations.nzf-test = {
    system = "x86_64-linux";
    modules = [
      inputs.home-manager.nixosModules.home-manager
      ./tests/vm.nix
    ];
  };
}
