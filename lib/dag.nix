{ lib }:

let
  inherit (lib) mapAttrs mapAttrsToList foldl' hasAttr;
  
  # DAG (Directed Acyclic Graph) implementation for plugin ordering
  
  # Create a DAG entry
  mkDAG = {
    data,
    before ? [],
    after ? [],
    dependsOn ? []
  }: {
    inherit data before after dependsOn;
  };
  
  # Topological sort implementation
  sortDAG = plugins:
    let
      # Convert plugins to DAG format if they aren't already
      pluginDAGs = mapAttrs (name: plugin: 
        if hasAttr "data" plugin then plugin
        else mkDAG { 
          data = plugin; 
          dependsOn = plugin.dependsOn or [];
        }
      ) plugins;
      
      # Build dependency graph
      buildGraph = plugins:
        let
          addDependencies = name: plugin: acc:
            let
              # Direct dependencies from dependsOn
              directDeps = plugin.dependsOn or [];
              
              # Dependencies from before/after relationships
              beforeDeps = lib.filter (dep: lib.elem name (plugins.${dep}.after or [])) (lib.attrNames plugins);
              afterDeps = plugin.after or [];
              
              allDeps = directDeps ++ beforeDeps ++ afterDeps;
            in
            acc // { ${name} = lib.unique allDeps; };
        in
        foldl' (acc: name: addDependencies name pluginDAGs.${name} acc) {} (lib.attrNames pluginDAGs);
      
      graph = buildGraph pluginDAGs;
      
      # Kahn's algorithm for topological sorting
      kahnSort = graph:
        let
          # Find nodes with no incoming edges
          findRoots = graph:
            let
              allNodes = lib.attrNames graph;
              nodesWithIncoming = lib.unique (lib.concatLists (lib.attrValues graph));
            in
            lib.filter (node: !(lib.elem node nodesWithIncoming)) allNodes;
          
          # Remove a node and its edges
          removeNode = node: graph:
            let
              withoutNode = lib.removeAttrs graph [node];
            in
            mapAttrs (n: deps: lib.filter (dep: dep != node) deps) withoutNode;
          
          # Recursive sorting
          sortRec = remaining: sorted:
            if remaining == {} then sorted
            else
              let
                roots = findRoots remaining;
              in
              if roots == [] then
                throw "Circular dependency detected in plugin configuration"
              else
                let
                  nextNode = lib.head roots;
                  newRemaining = removeNode nextNode remaining;
                in
                sortRec newRemaining (sorted ++ [nextNode]);
        in
        sortRec graph [];
      
      sortedNames = kahnSort graph;
      
    in
    # Return plugins in sorted order
    lib.listToAttrs (map (name: {
      inherit name;
      value = pluginDAGs.${name}.data;
    }) sortedNames);
  
  # Validate DAG for cycles
  validateDAG = plugins:
    let
      try = builtins.tryEval (sortDAG plugins);
    in
    if try.success then { valid = true; sorted = try.value; }
    else { valid = false; error = "Circular dependency detected"; };
    
in {
  inherit mkDAG sortDAG validateDAG;
}