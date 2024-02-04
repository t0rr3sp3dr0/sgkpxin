{ pkgs
, noVersioning
, noDefaulting
, ...
}:

let
  pkgSet = import ./mkPackages_pkgSet.nix { inherit pkgs noVersioning noDefaulting; };

  mkPackages = packages:
    pkgs.lib.pipe packages [ ( builtins.concatMap pkgSet ) builtins.listToAttrs ];
in

mkPackages
