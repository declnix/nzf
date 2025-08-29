{ lib, pkgs }:

{
  plugin = import ./types/plugin.nix { inherit lib pkgs; };
}
