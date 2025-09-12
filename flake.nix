{
  inputs = {
    flakelight.url = "github:nix-community/flakelight";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { flakelight, ... }@inputs: flakelight ./. { inherit inputs; };
}
