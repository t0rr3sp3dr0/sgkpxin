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
    description = "The IDE for pure Java and Kotlin development";
    longDescription = ''
      Free and built using open source code, IntelliJ IDEA Community Edition
      provides all of the essential features for productive Java and Kotlin
      development. It offers intelligent coding assistance, reliable
      refactorings, on-the-fly code analysis, instant code navigation, and more.
      
      To take your development experience to the next level, upgrade to IntelliJ
      IDEA Ultimate.
      
      Supported languages and technologies
      Java, Kotlin, Scala, Groovy, Gradle, Maven, debugger, decompiler, JUnit,
      Spock, Git, GitHub, Docker, and more
    '';
    homepage = "https://jetbrains.com/idea/";
    downloadPage = "https://jetbrains.com/idea/download/#section=mac";
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

  pname = "intellij-idea-community-edition";
  version = vars.version;
  src = fetchurl {
    url = "https://download.jetbrains.com/idea/ideaIC-${vars.version}${vars.variant}.dmg";
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

    mv -vf './IntelliJ IDEA CE.app' "''${out}/Applications"
    makeWrapper "''${out}/Applications/IntelliJ IDEA CE.app/Contents/MacOS/idea" "''${out}/bin/${pname}"

    runHook postInstall
  '';
  dontFixup = true;
}
