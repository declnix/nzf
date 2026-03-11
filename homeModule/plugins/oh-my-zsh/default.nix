{
  lib,
  ...
}:
let
  inherit (lib) mkOption types filterAttrs hasSuffix;

  importDir =
    dir:
    let
      files = builtins.readDir dir;
      nixFiles = filterAttrs (name: type: type == "regular" && hasSuffix ".nix" name) files;
    in
    map (name: dir + "/${name}") (builtins.attrNames nixFiles);
in
{
  imports = importDir ./lib ++ importDir ./plugins;

  options.programs.nzf.oh-my-zsh.plugins = mkOption {
    type = types.listOf types.str;
    default = [ ];
    description = "List of oh-my-zsh plugins to enable";
  };
}
