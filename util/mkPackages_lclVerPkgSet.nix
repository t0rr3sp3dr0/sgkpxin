{ ...
}:

let
  consts = import ./consts.nix { };

  versOf = import ./versOf.nix { };

  lclVer = drv: package: ver:
    {
      name = "${ package }${ consts.verSep }${ ver }";
      value = drv;
    };

  lclVerPkgSet = package: drv:
    builtins.map ( lclVer drv package ) ( versOf drv.version );
in

lclVerPkgSet
