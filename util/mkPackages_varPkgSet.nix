{ ...
}:

let
  defVarPkgSet = import ./mkPackages_defVarPkgSet.nix { };

  varPkgSet = package: drv:
    defVarPkgSet package drv;
in

varPkgSet
