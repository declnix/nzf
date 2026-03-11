{
  lib,
  ...
}:
let
  inherit (lib)
    mkOption
    types
    filterAttrs
    hasSuffix
    ;
in
{
  options.programs.nzf.oh-my-zsh.plugins = mkOption {
    type = types.listOf types.str;
    default = [ ];
    description = "List of oh-my-zsh plugins to enable";
  };
}
