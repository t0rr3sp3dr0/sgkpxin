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
    description = "Documentation authoring IDE";
    longDescription = ''
      Writerside is a new solution for documentation authoring from JetBrains.
      
      With Writerside, developers and technical writers can collaborate and
      create product docs, tutorials, developer guides, and API references in a
      single working environment.
      
      Docs-as-code out of the box:
      - Choose between Markdown and semantic markup or combine both
      - Preview your content instantly or open it in the browser
      - Single source support with filters and variables
      - Built-in Git integration, templates, snippets
      - Doc quality automation with 100+ checks
      - Generate REST API reference documentation
    '';
    homepage = "https://jetbrains.com/writerside/";
    downloadPage = "https://jetbrains.com/writerside/download/#section=mac";
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

  pname = "writerside";
  version = vars.version;
  src = fetchurl {
    url = "https://download-cdn.jetbrains.com/writerside/writerside-${vars.buildno}${vars.variant}.dmg";
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

    mv -vf './Writerside.app' "''${out}/Applications"
    makeWrapper "''${out}/Applications/Writerside.app/Contents/MacOS/writerside" "''${out}/bin/${pname}"

    runHook postInstall
  '';
  dontFixup = true;
}
