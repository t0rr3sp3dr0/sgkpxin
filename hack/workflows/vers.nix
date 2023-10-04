let
  platOf = package:
    ( import ../../. { } ).${ package }.meta.platforms;

  indexOf' = str: sub: idx:
    let
      strLen = builtins.stringLength str;
      subLen = builtins.stringLength sub;
    in
      if (
        strLen < subLen + idx
      ) then (
        -1
      ) else (
        if (
          builtins.substring idx subLen str == sub
        ) then (
          idx
        ) else (
          indexOf' str sub ( idx + 1 )
        )
      );

  indexOf = str: sub:
     indexOf' str sub 0;

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

  verElem = ver:
    {
      name = ver;
      value = "HEAD";
    };

  listToAttrsMap = f: list:
    builtins.listToAttrs ( builtins.map f list );

  sysElem = package: system:
    let
      ver = ( import ../../. { pkgs = import <nixpkgs> { inherit system; }; } ).${ package }.version;
    in
      {
        name = system;
        value = listToAttrsMap verElem ( versOf ver );
      };

  curVers = package:
    listToAttrsMap ( sysElem package ) ( platOf package );

  readOr = path: default:
    if ( builtins.pathExists path ) then ( builtins.readFile path ) else ( default );

  oldVers = package:
    builtins.fromJSON ( readOr ../../pkgs/${ package }/vers.json "{}" );

  newElem = old: cur: system:
    {
      name = system;
      value = ( old.${ system } or { } ) // ( cur.${ system } or { } );
    };

  newVers = old: cur:
    listToAttrsMap ( newElem old cur ) ( builtins.attrNames ( cur // old ) );
in
  builtins.toJSON (
    let
      package = builtins.replaceStrings [ "\r" "\n" ] [ "" "" ] ( builtins.readFile "/dev/stdin" );
    in
      newVers ( oldVers package ) ( curVers package )
  )
