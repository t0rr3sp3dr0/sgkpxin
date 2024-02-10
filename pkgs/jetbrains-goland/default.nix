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
    description = "An IDE for Go and Web";
    longDescription = ''
      GoLand makes it easy to read, write, and edit more than just Go code. It
      is fully equipped to handle web, frontend, and backend development, as
      well as work with databases. GoLand offers a host of smart features such
      as intelligent code completion, safe refactorings with one-step undo, a
      powerful built-in debugger, and on-the-fly error detection with
      quick-fixes. GoLand helps all Go developers, from novices to experienced
      professionals, create fast, efficient, and reliable code - and have more
      fun doing it.

      Supported languages and technologies
      Go, JavaScript, TypeScript, HTML, CSS, Dart, React, SASS, LESS, SQL and
      databases, Docker, Git, GitHub, and more
    '';
    homepage = "https://jetbrains.com/go/";
    downloadPage = "https://jetbrains.com/go/download/#section=mac";
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

  pname = "goland";
  version = vars.version;
  src = fetchurl {
    url = "https://download.jetbrains.com/go/goland-${vars.version}${vars.variant}.dmg";
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

    mv -vf './GoLand.app' "''${out}/Applications"
    makeWrapper "''${out}/Applications/GoLand.app/Contents/MacOS/goland" "''${out}/bin/${pname}"

    runHook postInstall
  '';
  dontFixup = true;
}
