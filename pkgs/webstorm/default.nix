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
    description = "A JavaScript IDE";
    longDescription = ''
      WebStorm is an integrated development environment for JavaScript and its
      related technologies. Just like other JetBrains IDEs, WebStorm makes your
      development experience more enjoyable, automating routine work and helping
      you handle complex tasks with ease.
      
      Supported languages and technologies
      JavaScript, TypeScript, Vue, React, Angular, Node.js, React Native,
      Electron, HTML, CSS, Tailwind CSS, Jest, Git, GitHub, and more
    '';
    homepage = "https://jetbrains.com/webstorm/";
    downloadPage = "https://jetbrains.com/webstorm/download/#section=mac";
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

  pname = "webstorm";
  version = vars.version;
  src = fetchurl {
    url = "https://download-cdn.jetbrains.com/webstorm/WebStorm-${vars.version}${vars.variant}.dmg";
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

    mv -vf './WebStorm.app' "''${out}/Applications"
    makeWrapper "''${out}/Applications/WebStorm.app/Contents/MacOS/webstorm" "''${out}/bin/${pname}"

    runHook postInstall
  '';
  dontFixup = true;
}
