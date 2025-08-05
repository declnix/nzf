{ lib, pkgs }:

let
  inherit (lib) concatStringsSep mapAttrsToList;
  
  # Create a lazy-loadable plugin wrapper
  mkLazyPlugin = {
    name,
    package ? null,
    triggers ? [],
    defer ? null,
    condition ? null
  }: {
    inherit name package triggers defer condition;
    type = "lazy";
  };
  
  # Generate deferred loading script using zsh-defer
  generateDeferredLoading = plugins:
    let
      # Group plugins by loading strategy
      immediate = lib.filterAttrs (n: p: !(p.lazy or true)) plugins;
      lazy = lib.filterAttrs (n: p: p.lazy or true) plugins;
      deferred = lib.filterAttrs (n: p: (p.defer or null) != null) lazy;
      conditional = lib.filterAttrs (n: p: (p.triggers or []) != []) lazy;
      
      # Generate immediate loading
      immediateScript = concatStringsSep "\n" (mapAttrsToList (name: plugin: ''
        # Immediate load: ${name}
        ${generatePluginLoader name plugin}
      '') immediate);
      
      # Generate deferred loading
      deferredScript = concatStringsSep "\n" (mapAttrsToList (name: plugin: ''
        # Deferred load: ${name} (${toString plugin.defer}s)
        zsh-defer -t ${toString plugin.defer} ${generatePluginLoader name plugin}
      '') deferred);
      
      # Generate conditional loading
      conditionalScript = generateConditionalLoading conditional;
      
    in ''
      # ZHF Lazy Loading System
      
      # Immediate plugins
      ${immediateScript}
      
      # Deferred plugins
      ${deferredScript}
      
      # Conditional plugins
      ${conditionalScript}
    '';
  
  # Generate plugin loader function
  generatePluginLoader = name: plugin: ''
    _zhf_load_${lib.replaceStrings ["-"] ["_"] name}() {
      if [[ -z "$_ZHF_LOADED_${lib.toUpper (lib.replaceStrings ["-"] ["_"] name)}" ]]; then
        ${plugin.before or ""}
        
        ${if plugin.package != null then ''
          # Load from package
          local plugin_file
          for plugin_file in \
            "${plugin.package}/share/zsh/${name}/${name}.plugin.zsh" \
            "${plugin.package}/share/zsh/${name}/${name}.zsh" \
            "${plugin.package}/share/${name}.zsh" \
            "${plugin.package}/${name}.plugin.zsh" \
            "${plugin.package}/${name}.zsh"; do
            if [[ -f "$plugin_file" ]]; then
              source "$plugin_file"
              break
            fi
          done
        '' else ''
          # Custom plugin loading logic
          echo "Loading custom plugin: ${name}"
        ''}
        
        ${plugin.after or ""}
        
        export _ZHF_LOADED_${lib.toUpper (lib.replaceStrings ["-"] ["_"] name)}=1
      fi
    }
    _zhf_load_${lib.replaceStrings ["-"] ["_"] name}
  '';
  
  # Generate conditional loading based on triggers
  generateConditionalLoading = plugins:
    let
      # Group by trigger types
      commandTriggers = lib.filterAttrs (n: p: lib.any (t: lib.hasPrefix "command:" t) p.triggers) plugins;
      eventTriggers = lib.filterAttrs (n: p: lib.any (t: lib.hasPrefix "event:" t) p.triggers) plugins;
      
      # Generate command-based triggers
      commandScript = concatStringsSep "\n" (lib.flatten (mapAttrsToList (name: plugin:
        let
          commands = lib.filter (t: lib.hasPrefix "command:") plugin.triggers;
          commandNames = map (t: lib.removePrefix "command:" t) commands;
        in
        map (cmd: ''
          # Command trigger for ${name}: ${cmd}
          ${cmd}() {
            _zhf_load_${lib.replaceStrings ["-"] ["_"] name}
            unfunction ${cmd}
            ${cmd} "$@"
          }
        '') commandNames
      ) commandTriggers));
      
      # Generate event-based triggers
      eventScript = concatStringsSep "\n" (mapAttrsToList (name: plugin:
        let
          events = lib.filter (t: lib.hasPrefix "event:") plugin.triggers;
          eventNames = map (t: lib.removePrefix "event:" t) events;
        in
        concatStringsSep "\n" (map (event: ''
          # Event trigger for ${name}: ${event}
          autoload -Uz add-zsh-hook
          _zhf_${lib.replaceStrings ["-"] ["_"] name}_${event}_hook() {
            _zhf_load_${lib.replaceStrings ["-"] ["_"] name}
            add-zsh-hook -d ${event} _zhf_${lib.replaceStrings ["-"] ["_"] name}_${event}_hook
          }
          add-zsh-hook ${event} _zhf_${lib.replaceStrings ["-"] ["_"] name}_${event}_hook
        '') eventNames)
      ) eventTriggers);
      
    in ''
      # Command-based conditional loading
      ${commandScript}
      
      # Event-based conditional loading  
      ${eventScript}
    '';
  
  # Generate performance monitoring
  generatePerformanceMonitoring = ''
    # ZHF Performance Monitoring
    typeset -A _ZHF_LOAD_TIMES
    
    _zhf_time_start() {
      _ZHF_START_TIME=$(($(date +%s%3N)))
    }
    
    _zhf_time_end() {
      local plugin_name="$1"
      local end_time=$(($(date +%s%3N)))
      _ZHF_LOAD_TIMES[$plugin_name]=$(($end_time - $_ZHF_START_TIME))
    }
    
    zhf-timing() {
      echo "ZHF Plugin Load Times:"
      for plugin in ''${(k)_ZHF_LOAD_TIMES}; do
        echo "  $plugin: ''${_ZHF_LOAD_TIMES[$plugin]}ms"
      done
    }
  '';

in {
  inherit mkLazyPlugin generateDeferredLoading generatePluginLoader generateConditionalLoading generatePerformanceMonitoring;
}