{ stdenv
, lib
, fetchurl
, unzip
, makeWrapper
}:

let
  vars = {
    hash = "sha256-K9VLq8ayc2ToDEwQfOG0ACZmI3H1bDXiWyn967KUKxk=";
    live = "https://sublimetext.com/updates/4/stable_update_check";
  };
in

stdenv.mkDerivation rec {
  nativeBuildInputs = [
    unzip
    makeWrapper
  ];
  meta = with lib; {
    description = "Text Editing, Done Right";
    longDescription = ''
      The sophisticated text editor for code, markup and prose.
    '';
    homepage = "https://sublimetext.com";
    downloadPage = "https://sublimetext.com/download";
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

  pname = "sublime-text";
  version = "4143";
  src = fetchurl {
    url = "https://download.sublimetext.com/sublime_text_build_${version}_mac.zip";
    sha256 = "${vars.hash}";
  };

  unpackPhase = ''
    runHook preUnpack

    unzip '${src}'

    runHook postUnpack
  '';
  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  dontCheck = true;
  installPhase = ''
    runHook preInstall

    mkdir -vp "''${out}/"{'Applications','bin'}

    mv -vf './Sublime Text.app' "''${out}/Applications"
    makeWrapper "''${out}/Applications/Sublime Text.app/Contents/MacOS/sublime_text" "''${out}/bin/${pname}"

    for BIN in "''${out}/Applications/Sublime Text.app/Contents/SharedSupport/bin/"*
    do
      BASENAME="$(basename "''${BIN}")"
      makeWrapper "''${BIN}" "''${out}/bin/''${BASENAME}"
    done

    runHook postInstall
  '';
  dontFixup = true;
}
