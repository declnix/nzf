{ config, inputs, lib, ... }:

{
  flake.lib.zshConfiguration =
    { pkgs
    , modules ? [ ]
    , specialArgs ? { }
    ,
    }:
    let
      evaluated = lib.evalModules {
        modules = config.nzf.modules ++ modules;
        specialArgs = {
          inherit inputs pkgs;
          dag = inputs.dag.lib { inherit lib; };
        } // specialArgs;
      };

      failedAssertions = builtins.filter (a: !a.assertion) evaluated.config.assertions;
      rcText =
        assert lib.assertMsg
          (failedAssertions == [ ])
          (lib.concatMapStringsSep "\n" (a: a.message) failedAssertions);
        evaluated.config.nzf.zsh.renderedRc;

      rcFile = pkgs.writeText "zshrc" rcText;
      wrapper = pkgs.runCommand "nzf-zsh" { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
        mkdir -p $out/bin
        cp ${rcFile} $out/.zshrc
        makeWrapper ${pkgs.zsh}/bin/zsh $out/bin/zsh --set ZDOTDIR $out
      '';
    in
    {
      inherit evaluated rcText rcFile wrapper;
    };
}
