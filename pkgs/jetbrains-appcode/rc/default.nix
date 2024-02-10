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
    description = "A smart IDE for iOS and macOS";
    longDescription = ''
      AppCode is a smart IDE for iOS and macOS. It helps to create mobile and
      desktop apps faster with powerful refactorings, thorough code analysis and
      lots of integrations for database management, version control, and more.

      Supported languages and technologies
      Swift, Objective-C, C, C++, JavaScript, HTML, CSS, Markdown
    '';
    homepage = "https://jetbrains.com/objc/";
    downloadPage = "https://jetbrains.com/objc/download/#section=mac";
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

  pname = "appcode";
  version = vars.version;
  src = fetchurl {
    url = "https://download.jetbrains.com/objc/AppCode-${vars.version}-RC${vars.variant}.dmg";
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

    mv -vf './AppCode.app' "''${out}/Applications"
    makeWrapper "''${out}/Applications/AppCode.app/Contents/MacOS/appcode" "''${out}/bin/${pname}"

    runHook postInstall
  '';
  dontFixup = true;
}
