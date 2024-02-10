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
    description = "An educational IDE for coding";
    longDescription = ''
      IntelliJ IDEA Edu is a free educational IDE for learning and teaching
      Java, Kotlin, Groovy, and Scala.
      
      As a learner, you can join a public programming course, work on JetBrains
      Academy projects, or enroll in a custom course prepared just for you by
      your teacher or co-worker.
      
      As an educator, you can impart your knowledge with code exercises that
      incorporate the assistance of integrated tests and hints, and you can
      share your courses publicly or privately with your students or coworkers.

      Supported languages and technologies
      Java, Kotlin, Groovy, Scala, Android, Maven, Gradle, sbt, SVN, Mercurial,
      Debugger, Decompiler, JUnit, Spock, Git, GitHub, and more
    '';
    homepage = "https://jetbrains.com/idea-edu/";
    downloadPage = "https://jetbrains.com/edu-products/download/#section=idea";
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

  pname = "intellij-idea-edu";
  version = vars.version;
  src = fetchurl {
    url = "https://download.jetbrains.com/idea/ideaIE-${vars.version}${vars.variant}.dmg";
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

    mv -vf './IntelliJ IDEA Edu.app' "''${out}/Applications"
    makeWrapper "''${out}/Applications/IntelliJ IDEA Edu.app/Contents/MacOS/idea" "''${out}/bin/${pname}"

    runHook postInstall
  '';
  dontFixup = true;
}
