{
  nzf.modules = [
    ({ config, lib, ... }:
    let
      inherit (lib) mkEnableOption;
      cfg = config.nzf.zsh.highlighting.integrations;
    in
    {
      options.nzf.zsh.highlighting.enable = mkEnableOption "zsh highlighting";

      config.assertions = [
        {
          assertion = !(cfg.patina.enable && cfg.zshSyntaxHighlighting.enable);
          message = "Only one NZF zsh highlighting integration can be enabled.";
        }
      ];
    })
  ];
}
