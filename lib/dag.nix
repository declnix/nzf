# From home-manager: https://github.com/nix-community/home-manager/blob/master/modules/lib/dag.nix
# Adapted from nvf: https://github.com/NotAShelf/nvf/blob/main/lib/dag.nix
# A generalization of Nixpkgs's `strings-with-deps.nix`.
{ lib }:
let
  inherit (builtins)
    isAttrs
    attrValues
    attrNames
    elem
    all
    head
    tail
    length
    toJSON
    isString
    removeAttrs
    ;
  inherit (lib.attrsets) filterAttrs mapAttrs;
  inherit (lib.lists) toposort;
in
rec {
  empty = { };

  isEntry = e: e ? data && e ? after && e ? before;
  isDag = dag: isAttrs dag && all isEntry (attrValues dag);

  topoSort =
    dag:
    let
      getDagBefore = name: attrNames (filterAttrs (_n: v: elem name v.before) dag);
      normalizedDag = mapAttrs (n: v: {
        name = n;
        inherit (v) data;
        after = v.after ++ getDagBefore n;
      }) dag;
      before = a: b: elem a.name b.after;
      sorted = toposort before (attrValues normalizedDag);
    in
    if sorted ? result then
      {
        result = builtins.map (v: { inherit (v) name data; }) sorted.result;
      }
    else
      sorted;

  map = f: mapAttrs (n: v: v // { data = f n v.data; });

  entryBetween = before: after: data: { inherit data before after; };

  entryAnywhere = entryBetween [ ] [ ];

  entryAfter = entryBetween [ ];
  entryBefore = before: entryBetween before [ ];

  entriesBetween =
    tag:
    let
      go =
        i: before: after: entries:
        let
          name = "${tag}-${toString i}";
        in
        if entries == [ ] then
          empty
        else if length entries == 1 then
          {
            "${name}" = entryBetween before after (head entries);
          }
        else
          {
            "${name}" = entryAfter after (head entries);
          }
          // go (i + 1) before [ name ] (tail entries);
    in
    go 0;

  entriesAnywhere = tag: entriesBetween tag [ ] [ ];
  entriesAfter = tag: entriesBetween tag [ ];
  entriesBefore = tag: before: entriesBetween tag before [ ];

  resolveDag =
    {
      name,
      dag,
      mapResult,
    }:
    let
      finalDag = mapAttrs (_: value: if isString value then entryAnywhere value else value) dag;
      sortedDag = topoSort finalDag;
      loopDetail = builtins.map (loops: removeAttrs loops [ "data" ]) sortedDag.loops;
      result =
        if sortedDag ? result then
          mapResult sortedDag.result
        else
          abort ("Dependency cycle in ${name}: " + toJSON loopDetail);
    in
    result;
}
