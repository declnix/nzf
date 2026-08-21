{ lib, ... }:

{
  options.nzf.modules = lib.mkOption {
    type = lib.types.listOf lib.types.deferredModule;
    default = [ ];
    description = "NZF zsh modules collected by flake-parts.";
  };
}
