{
  nzf.modules = [
    ({ pkgs, ... }:
    {
      config._module.args.nzfZshPlugins = {
        omzLib = name: "${pkgs.oh-my-zsh}/share/oh-my-zsh/lib/${name}.zsh";
        omzPlugin = name: "${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/${name}/${name}.plugin.zsh";
      };
    })
  ];
}
