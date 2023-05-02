{ stdenv
, lib
, fetchurl
, gnutar
, makeWrapper
}:

let
  vars = {
    hash = "sha256-Y82aSyp0hjK+fkl7h110mkfekVYKNygeFIWFi3RX4Yk=";
    live = "todo://";
    # live = "https://spclient.wg.spotify.com/desktop-update/v2/update";
    # live = "https://macupdater-backend.com/files/casks_automatic/spotify.rb";
  };
in

stdenv.mkDerivation rec {
  nativeBuildInputs = [
    gnutar
    makeWrapper
  ];
  meta = with lib; {
    description = "Discover the latest songs";
    longDescription = ''
      With the Spotify music and podcast app, you can play millions of songs,
      albums and original podcasts for free. Stream music and podcasts, discover
      albums, playlists or even single songs for free on your mobile or tablet.
      Subscribe to Spotify Premium to download and listen offline wherever you
      are.
    '';
    homepage = "https://spotify.com";
    downloadPage = "https://spotify.com/download";
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

  pname = "spotify";
  version = "1.2.10.760.g52970952-1108";
  src = fetchurl {
    url = "http://upgrade.scdn.co/upgrade/client/osx-x86_64/spotify-autoupdate-${version}.tbz";
    sha256 = "${vars.hash}";
  };

  unpackPhase = ''
    runHook preUnpack

    tar -xvjf '${src}'

    runHook postUnpack
  '';
  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  dontCheck = true;
  installPhase = ''
    runHook preInstall

    mkdir -vp "''${out}/"{'Applications/Spotify.app','bin'}

    mv -vf './Contents' "''${out}/Applications/Spotify.app"
    makeWrapper "''${out}/Applications/Spotify.app/Contents/MacOS/Spotify" "''${out}/bin/${pname}"

    runHook postInstall
  '';
  dontFixup = true;
}
