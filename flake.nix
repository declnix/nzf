{
  description = "ZHF - Zsh Framework with declarative configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      systems = flake-utils.lib.defaultSystems;
    in
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = nixpkgs.lib;

        # Load your framework (Home Manager module and lib functions)
        zhfLib = import ./lib/default.nix { inherit lib pkgs; };

        # Load the example config
        exampleConfig = import ./examples/basic.nix { inherit lib zhfLib; };

        # Build the rendered config (.zshrc)
        builtConfig = zhfLib.buildConfig {
          config = exampleConfig;
        };
      in {
        ############################
        ### Dev Shell
        ############################
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            zsh
            jq
            nixfmt-rfc-style
          ];

          shellHook = ''
            echo "🚀 ZHF Development Environment"
            echo "Available commands:"
            echo "  zhf-test    - View example config as JSON"
            echo "  zhf-build   - Write .zshrc to .tmp/.zshrc"
            echo "  zhf-reload  - Start Zsh using .tmp config"

            export ZHF_DEV=1
            export ZHF_ROOT=$(pwd)
            export ZDOTDIR=$ZHF_ROOT/.tmp
            mkdir -p "$ZDOTDIR"

            alias zhf-test="nix eval --json .#examples.basic --apply 'builtins.toJSON' | jq"
            alias zhf-build="nix eval --raw .#lib.builtConfig.${system} > $ZDOTDIR/.zshrc && echo '✅ .zshrc written to $ZDOTDIR/.zshrc'"
            alias zhf-reload="ZDOTDIR=$ZDOTDIR exec zsh"
          '';
        };

        ############################
        ### Module + Examples
        ############################
        homeManagerModules.default = zhfLib;

        examples = {
          basic = exampleConfig;
          advanced = import ./examples/advanced.nix { inherit lib zhfLib; };
        };

        ############################
        ### Optional Overlay
        ############################
        overlays.default = final: prev: {
          zhf = self.packages.${final.system}.default or {};
        };
      }
    )
    //
    {
      # ✅ Top-level access to rendered builtConfig
      lib.builtConfig = flake-utils.lib.eachDefaultSystem (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          lib = nixpkgs.lib;
          zhfLib = import ./lib/default.nix { inherit lib pkgs; };
          exampleConfig = import ./examples/basic.nix { inherit lib zhfLib; };
        in
          zhfLib.buildConfig {
            config = exampleConfig;
          }
      );
    };
}
