{ stdenv
, lib
, fetchurl
, undmg
, makeWrapper
}:

let
  data = builtins.fromJSON ( builtins.readFile ./vars.json );
  plat = stdenv.hostPlatform.system;
  vars = data.${plat} or ( data.universal-darwin or ( data.x86_64-darwin or ( throw "${plat} is not supported" )));
in

stdenv.mkDerivation rec {
  nativeBuildInputs = [
    undmg
    makeWrapper
  ];
  meta = with lib; {
    description = ".NET performance profiler";
    longDescription = ''
      dotTrace is a .NET performance profiler — a tool that helps you find out
      exactly what causes a .NET application to run slower than expected.
      Locating performance bottlenecks in a .NET application is easy with
      dotTrace, thanks to a rich user interface and robust processing of
      large-scale snapshots.
      
      Supported languages and technologies
      .NET, .NET Core, Mono, Unity, ASP.NET, ASP.NET Core, WCF, UWP, IIS
    '';
    homepage = "https://jetbrains.com/dottrace/";
    downloadPage = "https://jetbrains.com/dottrace/download/#section=portable";
    license = with licenses; [
      unfree
    ];
    sourceProvenance = with sourceTypes; [
      binaryNativeCode
    ];
    platforms = with platforms; [
      "aarch64-darwin"
      "x86_64-darwin"
    ];
  };

  pname = "dottrace";
  version = vars.version;
  src = fetchurl {
    url = "https://download-cdn.jetbrains.com/resharper/dotUltimate.${vars.version}/JetBrains.dotTrace.macos-${vars.variant}.${vars.version}.dmg";
    hash = vars.hash;
  };

  unpackPhase = ''
    runHook preUnpack

    undmg '${src}'

    runHook postUnpack
  '';
  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  dontCheck = true;
  installPhase = ''
    runHook preInstall

    mkdir -vp "''${out}/"{'Applications','bin'}

    mv -vf './dotTrace.app' "''${out}/Applications"
    makeWrapper "''${out}/Applications/dotTrace.app/Contents/MacOS/dottrace" "''${out}/bin/${pname}"

    runHook postInstall
  '';
  dontFixup = true;
}
