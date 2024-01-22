{ pkgs
, noVersioning
, ...
}:

let
  lclVerSet = import ./mkPackages_lclVerSet.nix { inherit pkgs noVersioning; };

  rmtVerSet = import ./mkPackages_rmtVerSet.nix { inherit pkgs noVersioning; };

  verSet = package:
    let
      lcl = lclVerSet package;
      rmt = rmtVerSet package;
    in
      lcl ++ rmt;

  mkPackages = packages:
    pkgs.lib.pipe packages [ ( builtins.concatMap verSet ) builtins.listToAttrs ];
in

mkPackages
