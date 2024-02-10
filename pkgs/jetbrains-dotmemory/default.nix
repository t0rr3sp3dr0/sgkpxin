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
    description = ".NET memory profiler";
    longDescription = ''
      dotMemory helps you optimize memory usage in a variety of .NET
      applications and answer questions related to poor memory management.
      
      Supported languages and technologies
      .NET and .NET Core, ASP.NET and ASP.NET Core, IIS
    '';
    homepage = "https://jetbrains.com/dotmemory/";
    downloadPage = "https://jetbrains.com/dotmemory/download/#section=mac";
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

  pname = "dotmemory";
  version = vars.version;
  src = fetchurl {
    url = "https://download.jetbrains.com/resharper/dotUltimate.${vars.version}/JetBrains.dotMemory.macos-${vars.variant}.${vars.version}.dmg";
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

    mv -vf './dotMemory.app' "''${out}/Applications"
    makeWrapper "''${out}/Applications/dotMemory.app/Contents/MacOS/dotmemory" "''${out}/bin/${pname}"

    runHook postInstall
  '';
  dontFixup = true;
}
