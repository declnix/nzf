{
  outputs =
    { flakelight, ... }:
    flakelight ./. (
      { lib, ... }:
      {
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
      }
    );

  inputs = {
    flakelight.url = "github:nix-community/flakelight";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };
}
