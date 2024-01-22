{ ...
}:

let
  indexOf = import ./indexOf.nix { };

  sepsOf' = ver: comps: compsIdx:
    if (
      builtins.length comps < compsIdx + 1
    ) then (
      [ ver ]
    ) else (
      let
        comp = builtins.elemAt comps compsIdx;
        compLen = builtins.stringLength comp;
        compIdx = indexOf ver comp;
        verPrefix = builtins.substring 0 compIdx ver;
        verSuffix = builtins.substring ( compIdx + compLen ) ( -1 ) ver;
      in
        [ verPrefix ] ++ ( sepsOf' verSuffix comps ( compsIdx + 1 ) )
    );

  sepsOf = ver: comps:
    sepsOf' ver comps 0;
in

sepsOf
