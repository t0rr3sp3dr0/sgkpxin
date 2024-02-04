{ pkgs
, noVersioning
, noDefaulting
, ...
}:

let
  consts = import ./consts.nix { };

  lstcatOr = import ./lstcatOr.nix { };

  varPkgSet = import ./mkPackages_varPkgSet.nix { };

  verPkgSet = import ./mkPackages_verPkgSet.nix { inherit pkgs; };

  stdenv = pkgs.${ consts.stdenv };

  pkgSetForVar = package: var:
    pkgSet "${ package }${ consts.varSep }${ var }";

  pkgSetForTyp = package: drv:
    {
      derivation =
        let
          cond = !noVersioning;
          base = [ { name = package; value = drv; } ];
          vers = verPkgSet package drv;
        in 
          lstcatOr cond base vers 0;

      metaderivation =
        let
          vers = builtins.concatMap ( pkgSetForVar package ) drv.variants;
          vars = varPkgSet package vers;
          defs = drv.defaults or false;
          cond = !noDefaulting && defs;
        in
          lstcatOr cond vars vers 1;
    };

  pkgSet = package:
    let
      drv = pkgs.callPackage ../pkgs/${ builtins.replaceStrings [ consts.varSep ] [ consts.pthSep ] package } { inherit stdenv; };
      typ = drv.type or null;
    in
      ( pkgSetForTyp package drv ).${ typ } or ( throw "unknown package type ${typ}" );
in

pkgSet
