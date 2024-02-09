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
    description = "A powerful IDE for Rust";
    longDescription = ''
      RustRover is a dedicated IDE for the Rust development. It's equipped with
      powerful refactorings, thorough code analysis and lots of integrations
      for web technologies, version control, database management, and more.
      
      Supported languages and technologies
      Rust, Cargo, TOML, JavaScript, HTML, CSS, SQL, Markdown
    '';
    homepage = "https://jetbrains.com/rustrover/";
    downloadPage = "https://jetbrains.com/rustrover/download/#section=mac";
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

  pname = "rustrover";
  version = vars.version;
  src = fetchurl {
    url = "https://download-cdn.jetbrains.com/rustrover/RustRover-${vars.version}${vars.variant}.dmg";
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

    mv -vf './RustRover.app' "''${out}/Applications"
    makeWrapper "''${out}/Applications/RustRover.app/Contents/MacOS/rustrover" "''${out}/bin/${pname}"

    runHook postInstall
  '';
  dontFixup = true;
}
