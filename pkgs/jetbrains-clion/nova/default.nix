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
    description = "CLion Nova preview, a faster IDE for C and C++";
    longDescription = ''
      CLion Nova is an early preview build of the CLion IDE with the C++
      language engine coming from ReSharper C++ and JetBrains Rider. The main
      goal of the preview is to address the long-standing performance and
      quality issues of CLion.
      
      CLion Nova guarantees:
      - Faster highlighting speeds, especially in the case of incremental code
      updates.
      - A more responsive UI.
      - Faster Find Usages.
      - Significantly fewer freezes and lags in refactorings.
      - Faster test indexing.
      - A unified user experience across all of our C++ tools (CLion, Rider,
      and ReSharper C++).
      
      Supported languages and technologies
      C, C++, Python, CMake, Makefile, and Bazel.
    '';
    homepage = "https://blog.jetbrains.com/clion/2023/11/clion-nova/";
    downloadPage = "https://jetbrains.com/clion/download/#section=mac";
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

  pname = "clion";
  version = vars.version;
  src = fetchurl {
    url = "https://download.jetbrains.com/cpp/clion_nova/CLion-${vars.buildno}${vars.variant}.dmg";
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

    mv -vf './CLion ${version} EAP.app' "''${out}/Applications"
    makeWrapper "''${out}/Applications/CLion ${version} EAP.app/Contents/MacOS/clion" "''${out}/bin/${pname}"

    runHook postInstall
  '';
  dontFixup = true;
}
