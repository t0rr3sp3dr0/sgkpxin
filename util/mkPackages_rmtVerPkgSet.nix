{ pkgs
, ...
}:

let
  consts = import ./consts.nix { };

  readOr = import ./readOr.nix { };

  stdenv = pkgs.${ consts.stdenv };

  pkgsAt = gitRev:
    let
      gitURL = ../.;
    in
      import ( builtins.fetchGit { url = gitURL; rev = gitRev; } ) { inherit pkgs; };

  versAS = package:
    let
      plat = stdenv.hostPlatform.system;
      vers = builtins.fromJSON ( readOr ../pkgs/${ builtins.replaceStrings [ consts.varSep ] [ consts.pthSep ] package }/vers.json "{}" );
    in
      ( vers.x86_64-darwin or { } ) // ( vers.universal-darwin or { } ) // ( vers.${ plat } or { } );

  rmtVer = package: ver: rev:
    rec {
      name = "${ package }${ consts.verSep }${ ver }";
      value = ( pkgsAt rev ).${ name };
    };

  rmtVerPkgSet = package:
    pkgs.lib.attrsets.mapAttrsToList ( rmtVer package ) ( versAS package );
in

rmtVerPkgSet
