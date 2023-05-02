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
    description = "An educational IDE for Python";
    longDescription = ''
      PyCharm Edu is a free educational IDE for learning and teaching Python.
      
      As a learner, you can join a public programming course, enroll in a custom
      course prepared just for you by your teacher or co-worker, or work on
      JetBrains Academy projects.
      
      As an educator, you can impart your knowledge with code exercises that
      incorporate the assistance of integrated tests and hints, and you can
      share your courses publicly or privately with your students or coworkers.

      Supported languages and technologies
      Python, Debugger, Test Runner, CVS, Git, GitHub, Mercurial, Subversion,
      Conda Integration, and more
    '';
    homepage = "https://jetbrains.com/pycharm-edu/";
    downloadPage = "https://jetbrains.com/education/download/#section=pycharm-edu";
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

  pname = "pycharm-edu";
  version = vars.version;
  src = fetchurl {
    url = "https://download-cdn.jetbrains.com/python/pycharm-edu-${vars.version}${vars.variant}.dmg";
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

    mv -vf './PyCharm Edu.app' "''${out}/Applications"
    makeWrapper "''${out}/Applications/PyCharm Edu.app/Contents/MacOS/pycharm" "''${out}/bin/${pname}"

    runHook postInstall
  '';
  dontFixup = true;
}
