{ ...
}:

let
  indexOf' = str: sub: idx:
    let
      strLen = builtins.stringLength str;
      subLen = builtins.stringLength sub;
    in
      if (
        strLen < subLen + idx
      ) then (
        -1
      ) else (
        if (
          builtins.substring idx subLen str == sub
        ) then (
          idx
        ) else (
          indexOf' str sub ( idx + 1 )
        )
      );

  indexOf = str: sub:
    indexOf' str sub 0;
in

indexOf
