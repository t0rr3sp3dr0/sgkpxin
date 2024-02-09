{ stdenv
, lib
, fetchurl
, undmg
, makeWrapper
}:

let
  vars = {
    hash = "sha256-NqXfGpMBCtvcZ1+/dwLGcVdk7Lq18cLODKRRQSrhhUM=";
    live = "todo://";
  };
in

stdenv.mkDerivation rec {
  nativeBuildInputs = [
    undmg
    makeWrapper
  ];
  meta = with lib; {
    description = "Talk. Chat. Collaborate.";
    longDescription = ''
      Skype is the best way to stay connected with anyone, anywhere, anytime.
      Whether you want to talk to your family, friends or colleagues. You can
      make free video calls with up to 100 people, send and receive text
      messages, use ChatGPT with others, send voice messages, emojis, share your
      screen to show what you're working on.
    '';
    homepage = "http://skype.com";
    downloadPage = "https://skype.com/download";
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

  pname = "skype";
  version = "8.98.0.402";
  src = fetchurl {
    url = "https://download.skype.com/s4l/download/mac/Skype-${version}.dmg";
    sha256 = "${vars.hash}";
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

    mv -vf './Skype.app' "''${out}/Applications"
    makeWrapper "''${out}/Applications/Skype.app/Contents/MacOS/Skype" "''${out}/bin/${pname}"

    runHook postInstall
  '';
  dontFixup = true;
}
