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
    description = "A powerful IDE for test automation";
    longDescription = ''
      Aqua is a powerful test automation IDE that provides support for JVM,
      Python, and JavaScript test automation frameworks.
      
      Aqua brings an embedded Web Inspector with CSS and XPath locators, smart
      syntax highlighting, navigation, and code completion for CSS selectors and
      XPath. It helps you develop all kinds of automated tests with the most
      popular frameworks and perform advanced code-based HTTP requests. Aqua
      works with multiple database types, allowing engineers to configure a
      comprehensive work environment in a single place.
      
      Supported languages and technologies
      Kotlin, Java, Python, the JVM, Selenium, Cypress (coming soon), JUnit,
      TestNG, pytest, OpenAPI (Swagger), an HTTP client for APIs
    '';
    homepage = "https://jetbrains.com/aqua/";
    downloadPage = "https://jetbrains.com/aqua/download/#section=mac";
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

  pname = "aqua";
  version = vars.version;
  src = fetchurl {
    url = "https://download-cdn.jetbrains.com/aqua/aqua-${vars.buildno}${vars.variant}.dmg";
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

    mv -vf './Aqua ${version} EAP.app' "''${out}/Applications"
    makeWrapper "''${out}/Applications/Aqua ${version} EAP.app/Contents/MacOS/aqua" "''${out}/bin/${pname}"

    runHook postInstall
  '';
  dontFixup = true;
}
