{ lib, pkgs }:

let
  # Import all plugin definitions
  pluginFiles = builtins.readDir ./.;
  
  # Filter for .nix files and import them
  importPlugin = name: type:
    if type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix"
    then 
      let pluginName = lib.removeSuffix ".nix" name;
      in lib.nameValuePair pluginName (import (./. + "/${name}") { inherit lib pkgs; })
    else null;
  
  pluginImports = lib.mapAttrsToList importPlugin pluginFiles;
  validPlugins = lib.filter (x: x != null) pluginImports;
  
in
# Convert list of name-value pairs to attribute set
lib.listToAttrs validPlugins