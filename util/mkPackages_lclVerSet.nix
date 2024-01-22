{ pkgs
, noVersioning
, ...
}:

let
  consts = import ./consts.nix { };

  versOf = import ./versOf.nix { };

  stdenv = pkgs.${ consts.stdenv };

  pinVer = drv: package: ver:
    {
      name = "${ package }${ consts.verSep }${ ver }";
      value = drv;
    };

  pinVerSet = as:
    [ as ] ++ ( if ( noVersioning ) then ( [ ] ) else ( builtins.map ( pinVer as.value as.name ) ( versOf as.value.version ) ) );

  regVer = package: drv:
    {
      name = package;
      value = drv;
    };

  regVerSet = package: drv:
    pinVerSet ( regVer package drv );

  lstVer = as:
    {
      name = builtins.concatStringsSep "" ( builtins.match "(.+)${ consts.varSep }[^${ consts.verSep }]+(.*)" as.name );
      value = as.value;
    };

  lstVerSet = as:
    ( if ( noVersioning ) then ( [ ] ) else ( [ ( lstVer as ) ] ) ) ++ [ as ];

  varVerSet = package: variant:
    let
      drv = pkgs.callPackage ../pkgs/${ package }/${ variant } { inherit stdenv; };
      set = regVerSet "${ package }${ consts.varSep }${ variant }" drv;
    in
      builtins.concatMap lstVerSet set;

  typVerSet = package: drv:
    {
      derivation =
        regVerSet package drv;

      metaderivation =
        builtins.concatMap ( varVerSet package ) drv.variants;
    };

  lclVerSet = package:
    let
      drv = pkgs.callPackage ../pkgs/${ package } { inherit stdenv; };
      typ = drv.type or null;
    in
      ( typVerSet package drv ).${ typ } or ( throw "unknown package type ${typ}" );
in

lclVerSet
