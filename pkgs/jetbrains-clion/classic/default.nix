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
    description = "A cross-platform C and C++ IDE";
    longDescription = ''
      CLion is a smart cross-platform IDE for developing in C and C++ built on
      the IntelliJ platform. It brings coding assistance, on-the-fly code
      analysis with quick-fixes, and safe and automated refactorings to C and
      C++ developers on all three major platforms (Linux, Windows, and macOS).
      It fits local and remote development workflows as well as the development
      of embedded systems.

      Supported languages and technologies
      C, C++, Objective-C, Swift, Rust, Python, CMake, Makefile, Gradle
    '';
    homepage = "https://jetbrains.com/clion/";
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
    url = "https://download.jetbrains.com/cpp/CLion-${vars.version}${vars.variant}.dmg";
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

    mv -vf './CLion.app' "''${out}/Applications"
    makeWrapper "''${out}/Applications/CLion.app/Contents/MacOS/clion" "''${out}/bin/${pname}"

    runHook postInstall
  '';
  dontFixup = true;
}
