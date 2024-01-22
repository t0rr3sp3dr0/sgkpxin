{ ...
}:

let
  readOr = path: default:
    if ( builtins.pathExists path ) then ( builtins.readFile path ) else ( default );
in

readOr
