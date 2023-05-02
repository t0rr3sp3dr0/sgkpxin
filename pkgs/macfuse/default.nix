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
    hash = "sha256-nfclcxWpual6m6OnYBHKvte8N4RRW2n6CY+Nge/scm0=";
    # live = "https://github.com/osxfuse/osxfuse/releases/";
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

  pname = "macfuse";
  version = "4.5.0";
  src = fetchurl {
    url = "https://github.com/osxfuse/osxfuse/releases/download/macfuse-${version}/macfuse-${version}.dmg";
    sha256 = "${vars.hash}";
  };

  unpackPhase = ''
    runHook preUnpack

    undmg '${src}'

    xar -vxf './Install macFUSE.pkg'

    zcat -vf './Core.pkg/Payload' | cpio -vi
    zcat -vf './PreferencePane.pkg/Payload' | cpio -vi

    runHook postUnpack
  '';
  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  dontCheck = true;
  installPhase = ''
    runHook preInstall

    mkdir -vp "''${out}/"{'Library/'{'Filesystems','Frameworks','PreferencePanes'},'usr/local'}

    # Core.pkg
    mv -vf './Library/Filesystems/macfuse.fs' "''${out}/Library/Filesystems"
    mv -vf './Library/Frameworks/macFUSE.framework' "''${out}/Library/Frameworks"
    mv -vf './Library/Frameworks/OSXFUSE.framework' "''${out}/Library/Frameworks"
    mv -vf './usr/local/'* "''${out}/usr/local"

    # PreferencePane.pkg
    mv -vf './Library/PreferencePanes/macFUSE.prefPane' "''${out}/Library/PreferencePanes"

    runHook postInstall
  '';
  dontFixup = true;
}
