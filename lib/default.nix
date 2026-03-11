{ lib }:
let
  dag = import ./dag.nix { inherit lib; };
in
dag
// {
  plugin = pkg: "source ${pkg}/share/${pkg.pname}/${pkg.pname}.plugin.zsh";

  pluginFile = pkg: file: "source ${pkg}/${file}";

  defer =
    script:
    let
      hash = builtins.substring 0 8 (builtins.hashString "md5" script);
    in
    ''
      __nzf_${hash}() {
        ${script}
      }
      zsh-defer __nzf_${hash}
    '';

  fromZshPlugins =
    plugins:
    lib.listToAttrs (
      map (p: {
        name = p.name;
        value = dag.entryAnywhere "source ${p.src}/${p.file}";
      }) plugins
    );
}
