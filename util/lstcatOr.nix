{ ...
}:

let
  lstcatOr = cond: lhs: rhs: side:
    if ( cond ) then ( lhs ++ rhs ) else ( if ( side == 0 ) then ( lhs ) else ( rhs ) );
in

lstcatOr
