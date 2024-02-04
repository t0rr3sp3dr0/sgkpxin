{ ...
}:

let
  consts = import ./consts.nix { };

  defVar = package: { name, value }:
    {
      name = "${ package }${ builtins.head ( builtins.match "[^${ consts.verSep }]+(.*)" name ) }";
      value = value;
    };

  defVarPkgSet = package: vers:
    builtins.map ( defVar package ) vers;
in

defVarPkgSet
