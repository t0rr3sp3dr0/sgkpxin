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
    description = "An IDE for DSL development";
    longDescription = ''
      MPS is an open source IDE for developing external domain-specific
      languages (DSLs). MPS began as a research prototype with the goal of
      changing the paradigm of how programming is done. Now it is being used
      every day to solve complex real-world problems. Our clients are using it
      across a diverse spectrum of areas, ranging from the automotive and
      healthcare industries to tax return calculation for an entire country.
      
      Supported languages and technologies
      DSLs
    '';
    homepage = "https://jetbrains.com/mps/";
    downloadPage = "https://jetbrains.com/mps/download/#section=mac";
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

  pname = "mps";
  version = vars.version;
  src = fetchurl {
    url = "https://download.jetbrains.com/mps/${vars.version}/MPS-${vars.version}-macos${vars.variant}.dmg";
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

    mv -vf './MPS ${version}.app' "''${out}/Applications"
    makeWrapper "''${out}/Applications/MPS ${version}.app/Contents/MacOS/mps" "''${out}/bin/${pname}"

    runHook postInstall
  '';
  dontFixup = true;
}
