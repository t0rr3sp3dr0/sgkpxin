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
    description = "The Leading Java and Kotlin IDE";
    longDescription = ''
      IntelliJ IDEA is the leading IDE for Java and Kotlin development. It helps
      you stay productive with a suite of efficiency-enhancing features such as
      intelligent coding assistance, reliable refactorings, instant code
      navigation, built-in developer tools, web and enterprise development
      support, and much more.

      Supported languages and technologies
      Java, Kotlin, Scala, Groovy, Gradle, Maven, Spring, Spring Boot, Jakarta
      EE, Micronaut, Quarkus, Helidon, JavaScript, TypeScript, HTML, CSS, Vue,
      React, Angular, Node.js, React Native, Electron, database tools, HTTP
      Client, profiling tools, application servers, debugger, decompiler, JUnit,
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

  pname = "intellij-idea-ultimate";
  version = vars.version;
  src = fetchurl {
    url = "https://download-cdn.jetbrains.com/idea/ideaIU-${vars.version}${vars.variant}.dmg";
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

    mv -vf './IntelliJ IDEA.app' "''${out}/Applications"
    makeWrapper "''${out}/Applications/IntelliJ IDEA.app/Contents/MacOS/idea" "''${out}/bin/${pname}"

    runHook postInstall
  '';
  dontFixup = true;
}
