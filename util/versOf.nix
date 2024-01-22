{ ...
}:

let
  sepsOf = import ./sepsOf.nix { };

  versOf' = prefix: comps: seps: idx:
    if (
      builtins.length seps < idx + 1
    ) then (
      [ ]
    ) else (
      let
        sep = builtins.elemAt seps idx;
      in
        if (
          builtins.length comps < idx + 1
        ) then (
          if (
            sep == ""
          ) then (
            [ ]
          ) else (
            [ "${ prefix }${ sep }" ]
          )
        ) else (
          let
            comp = builtins.elemAt comps idx;
            ver = "${ prefix }${ sep }${ comp }";
          in
            [ ver ] ++ ( versOf' ver comps seps ( idx + 1 ) )
        )
    );

  versOf = ver:
    let
      comps = builtins.splitVersion ver;
      seps = sepsOf ver comps;
    in
      versOf' "" comps seps 0;
in

versOf
