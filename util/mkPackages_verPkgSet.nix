{ pkgs
, ...
}:

let
  lclVerPkgSet = import ./mkPackages_lclVerPkgSet.nix { };

  rmtVerPkgSet = import ./mkPackages_rmtVerPkgSet.nix { inherit pkgs; };

  verPkgSet = package: drv:
    ( lclVerPkgSet package drv ) ++ ( rmtVerPkgSet package );
in

verPkgSet
