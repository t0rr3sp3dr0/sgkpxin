let
  versOf = import ../../util/versOf.nix { };

  platOf = package:
    ( import ../../. { noVersioning = true; noDefaulting = true; } ).${ package }.meta.platforms;

  verElem = ver:
    {
      name = ver;
      value = "HEAD";
    };

  listToAttrsMap = f: list:
    builtins.listToAttrs ( builtins.map f list );

  sysElem = package: system:
    let
      ver = ( import ../../. { pkgs = import <nixpkgs> { inherit system; }; noVersioning = true; noDefaulting = true; } ).${ package }.version;
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
