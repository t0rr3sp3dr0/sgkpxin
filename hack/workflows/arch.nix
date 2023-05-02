builtins.toJSON ( map ( e: e.name ) ( with ( import <nixpkgs> { } ).lib.systems.parse.cpuTypes; [ aarch64 x86_64 ] ) )
