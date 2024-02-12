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
    description = "A JavaScript and TypeScript IDE";
    longDescription = ''
      WebStorm is an integrated development environment (IDE) by JetBrains. It
      includes everything you need for JavaScript and TypeScript development and
      lets you get straight to coding. WebStorm also makes it easy to tackle the
      most challenging tasks. Whether you're resolving Git merge conflicts or
      renaming a symbol across multiple files, it takes just a few clicks.
      
      Supported languages and technologies
      JavaScript, TypeScript, HTML, Markdown, CSS, Node.js, Vue, React, Angular,
      Svelte, Tailwind CSS, React Native, Electron, Astro, Jest, Vitest,
      Prettier, ESLint, Git, GitHub, and more
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
    url = "https://download.jetbrains.com/webstorm/WebStorm-${vars.version}${vars.variant}.dmg";
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
