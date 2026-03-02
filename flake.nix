{
  description = "A very basic flake";

  inputs = {
    # ===========================================================
    # CHANNELS
    # ===========================================================
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    # ===========================================================
    # FRAMEWORKS
    # ===========================================================
    flakelight = {
      url = "github:nix-community/flakelight";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ flakelight, ... }: (flakelight ./.) (import ./outputs.nix inputs);
}
