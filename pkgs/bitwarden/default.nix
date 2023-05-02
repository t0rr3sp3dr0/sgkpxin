{ stdenv
, lib
, fetchurl
, unzip
, makeWrapper
}:

let
  vars = {
    hash = "sha256-pMZYKvOqEFNSmPKJatqe4hHe2ejzX8WS+VvJuSeua7s=";
    live = "https://vault.bitwarden.com/download/?app=desktop&platform=macos&variant=dmg";
  };
in

stdenv.mkDerivation rec {
  nativeBuildInputs = [
    unzip
    makeWrapper
  ];
  meta = with lib; {
    description = "Move fast and securely with the password manager trusted by millions.";
    longDescription = ''
      Drive collaboration, boost productivity, and experience the power of open
      source with Bitwarden, the easiest way to secure all your passwords and
      sensitive information.
    '';
    homepage = "https://bitwarden.com";
    downloadPage = "https://bitwarden.com/download";
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

  pname = "bitwarden";
  version = "2023.5.0";
  src = fetchurl {
    url = "https://github.com/bitwarden/clients/releases/download/desktop-v${version}/Bitwarden-${version}-universal-mac.zip";
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

    mv -vf './Bitwarden.app' "''${out}/Applications"
    makeWrapper "''${out}/Applications/Bitwarden.app/Contents/MacOS/Bitwarden" "''${out}/bin/${pname}"

    runHook postInstall
  '';
  dontFixup = true;
}
