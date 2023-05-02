{ stdenv
, lib
, fetchurl
, undmg
, makeWrapper
}:

let
  vars = {
    hash = "sha256-kw0mhba1Laa5B8TYvlcEQItzMrZN4ZdFier/FtVtRH0=";
    live = "https://download.mozilla.org/?product=firefox-latest-ssl&os=osx";
  };
in

stdenv.mkDerivation rec {
  nativeBuildInputs = [
    undmg
    makeWrapper
  ];
  meta = with lib; {
    description = "Get the browser that protects what's important";
    longDescription = ''
      No shady privacy policies or back doors for advertisers. Just a lightning
      fast browser that doesn't sell you out.
    '';
    homepage = "https://mozilla.org/firefox";
    downloadPage = "https://mozilla.org/firefox/download";
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

  pname = "firefox";
  version = "112.0.2";
  src = fetchurl {
    url = "https://download-installer.cdn.mozilla.net/pub/firefox/releases/${version}/mac/en-US/Firefox%20${version}.dmg";
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

    mv -vf './Firefox.app' "''${out}/Applications"
    makeWrapper "''${out}/Applications/Firefox.app/Contents/MacOS/firefox" "''${out}/bin/${pname}"

    runHook postInstall
  '';
  dontFixup = true;
}
