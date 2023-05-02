{ stdenv
, lib
, fetchurl
, undmg
, xar
, cpio
, makeWrapper
}:

let
  vars = {
    hash = "b5feba01b2dfb740693106cef591a906eef1452d80c1b2bb8372afb5023718f9";
    live = "https://static.adtidy.org/mac/adguard-release-appcast.xml";
  };
in

stdenv.mkDerivation rec {
  nativeBuildInputs = [
    undmg
    xar
    cpio
    makeWrapper
  ];
  meta = with lib; {
    description = "Ultimate adblock";
    longDescription = ''
      AdGuard is an ultra-efficient ad blocker for Safari. It will not only
      remove annoying ads but also secure your privacy with advanced tracking
      protection.
    '';
    homepage = "https://adguard.com";
    downloadPage = "https://adguard.com/adguard-mac/overview.html";
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

  pname = "adguard";
  version = "2.9.2.1234";
  src = fetchurl {
    url = "https://static.adtidy.org/mac/release/AdGuard-${version}.dmg";
    sha256 = "${vars.hash}";
  };

  unpackPhase = ''
    runHook preUnpack

    undmg '${src}'

    xar -vxf './AdGuard.pkg'

    zcat -vf './app.pkg/Payload' | cpio -vi

    runHook postUnpack
  '';
  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  dontCheck = true;
  installPhase = ''
    runHook preInstall

    mkdir -vp "''${out}/"{'Applications','bin'}

    mv -vf './Adguard.app' "''${out}/Applications"
    makeWrapper "''${out}/Applications/Adguard.app/Contents/MacOS/Adguard" "''${out}/bin/adguard"

    runHook postInstall
  '';
  dontFixup = true;
}
