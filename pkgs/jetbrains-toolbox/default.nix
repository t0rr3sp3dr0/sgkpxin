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
    description = "A control panel for your tools and projects";
    longDescription = ''
    '';
    homepage = "https://jetbrains.com/toolbox-app";
    downloadPage = "https://jetbrains.com/toolbox-app/download";
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

  pname = "jetbrains-toolbox";
  version = vars.version;
  src = fetchurl {
    url = "https://download-cdn.jetbrains.com/toolbox/jetbrains-toolbox-${vars.buildno}${vars.variant}.dmg";
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

    mv -vf './JetBrains Toolbox.app' "''${out}/Applications"
    makeWrapper "''${out}/Applications/JetBrains Toolbox.app/Contents/MacOS/jetbrains-toolbox" "''${out}/bin/${pname}"

    runHook postInstall
  '';
  dontFixup = true;
}
