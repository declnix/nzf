pkgs: {
  packages = with pkgs; [ nixfmt-rfc-style lefthook gnumake ];

  shellHook = ''
    if [[ -d .git && -f .lefthook.yml && -z "$_LEFTHOOK_INSTALLED" ]]; then
      export _LEFTHOOK_INSTALLED=1
      lefthook install
    fi
  '';
}
