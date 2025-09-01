{ lib, pkgs }:

with lib;
types.submodule {
  options = {
    config = mkOption {
      type = types.lines;
      default = "";
      description = "The configuration script for the plugin.";
    };

    after = mkOption {
      type = with types; listOf str;
      default = [ ];
      description = "A list of plugins declarations that should be loaded before this one.";
    };

    extraPackages = mkOption {
      type = with types; listOf package;
      default = [ ];
      description = "A list of extra packages required by the plugin.";
    };

    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable the plugin.";
    };

    defer = mkOption {
      type = types.bool;
      default = false;
      description = "Defer loading of the plugin.";
    };
  };
}
