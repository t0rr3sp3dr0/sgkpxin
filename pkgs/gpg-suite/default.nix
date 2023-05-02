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
    hash = "sha256-rsD0oRTqgDRg8gWZqlQ3YIvFCoabCApby8GFxNBO2mA=";
    # live = "https://gpgtools.org/download";
    # live = "https://gpgtools.org/releases/gpgpreferences/appcast.xml";
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
    description = "One simple package with everything you need, to protect your emails and files.";
    longDescription = ''
      Use GPG Suite to encrypt, decrypt, sign and verify files or messages.
      Manage your GPG Keychain with a few simple clicks and experience the full
      power of GPG easier than ever before.
    '';
    homepage = "https://gpgtools.org";
    downloadPage = "https://gpgtools.org";
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

  pname = "gpg-suite";
  version = "2023.2";
  src = fetchurl {
    url = "https://releases.gpgtools.com/GPG_Suite-${version}.dmg";
    sha256 = "${vars.hash}";
  };

  unpackPhase = ''
    runHook preUnpack

    undmg '${src}'

    xar -vxf './Install.pkg'

    # zcat -vf './CheckPrivateKey.pkg/Payload' | cpio -vi
    zcat -vf './GPGKeychain_Core.pkg/Payload' | cpio -vi
    # zcat -vf './GPGMailLoader_Core.pkg/Payload' | cpio -vi
    # zcat -vf './GPGMail_12_Core.pkg/Payload' | cpio -vi
    # zcat -vf './GPGMail_3_Core.pkg/Payload' | cpio -vi
    # zcat -vf './GPGMail_4_Core.pkg/Payload' | cpio -vi
    # zcat -vf './GPGMail_5_Core.pkg/Payload' | cpio -vi
    # zcat -vf './GPGMail_6_Core.pkg/Payload' | cpio -vi
    # zcat -vf './GPGMail_7_Core.pkg/Payload' | cpio -vi
    zcat -vf './GPGPreferences_Core.pkg/Payload' | cpio -vi
    zcat -vf './GPGServices_Core.pkg/Payload' | cpio -vi
    zcat -vf './LibmacgpgXPC_Core.pkg/Payload' | cpio -vi
    zcat -vf './Libmacgpg_Core.pkg/Payload' | cpio -vi
    zcat -vf './MacGPG2.1_Core.pkg/Payload' | cpio -vi
    # zcat -vf './Updater_Core.pkg/Payload' | cpio -vi
    # zcat -vf './key.pkg/Payload' | cpio -vi
    zcat -vf './pinentry_Core.pkg/Payload' | cpio -vi
    # zcat -vf './preinstall.pkg/Payload' | cpio -vi
    zcat -vf './version.pkg/Payload' | cpio -vi

    runHook postUnpack
  '';
  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  dontCheck = true;
  installPhase = ''
    runHook preInstall

    mkdir -vp "''${out}/"{'Applications','Library/'{'Application Support','Frameworks','LaunchAgents','PreferencePanes','Services'},'bin','opt'}

    # GPGKeychain_Core.pkg
    mv -vf './GPG Keychain.app' "''${out}/Applications"
    makeWrapper "''${out}/Applications/GPG Keychain.app/Contents/MacOS/GPG Keychain" "''${out}/bin/gpg-keychain"

    # GPGPreferences_Core.pkg
    mv -vf './GPGPreferences.prefPane' "''${out}/Library/PreferencePanes"

    # GPGServices_Core.pkg
    mv -vf './GPGServices.service' "''${out}/Library/Services"
    # /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister "''${out}/Library/Services/GPGServices.service"

    # LibmacgpgXPC_Core.pkg
    mv -vf './Library/Application Support/GPGTools' "''${out}/Library/Application Support"
    mv -vf './Library/LaunchAgents/org.gpgtools.Libmacgpg.xpc.plist' "''${out}/Library/LaunchAgents"
    # launchctl load -w /Library/LaunchAgents/org.gpgtools.Libmacgpg.xpc.plist

    # Libmacgpg_Core.pkg
    mv -vf './Libmacgpg.framework' "''${out}/Library/Frameworks"

    # MacGPG2.1_Core.pkg
    mv -vf './Library/LaunchAgents/org.gpgtools.macgpg2.fix.plist' "''${out}/Library/LaunchAgents"
    # launchctl load -w /Library/LaunchAgents/org.gpgtools.macgpg2.fix.plist
    mv -vf './Library/LaunchAgents/org.gpgtools.macgpg2.shutdown-gpg-agent.plist' "''${out}/Library/LaunchAgents"
    # launchctl load -w /Library/LaunchAgents/org.gpgtools.macgpg2.shutdown-gpg-agent.plist
    mv -vf './private/tmp/org.gpgtools/MacGPG2' "''${out}/opt"
  	# cat "''${out}/opt/MacGPG2/share/gnupg/sks-keyservers.netCA.pem" > "''${out}/opt/MacGPG2/share/ca-certs.crt"
	  # /usr/bin/security find-certificate -a -p /System/Library/Keychains/SystemRootCertificates.keychain >> "''${out}/opt/MacGPG2/share/ca-certs.crt"
    for BIN in "''${out}/opt/MacGPG2/bin/"*
    do
      BASENAME="$(basename "''${BIN}")"
      makeWrapper "''${BIN}" "''${out}/bin/''${BASENAME}"
    done

    # pinentry_Core.pkg
    mv -vf './pinentry-mac.app' "''${out}/opt/MacGPG2/libexec"

    # version.pkg
    mv -vf './version.plist' "''${out}/Library/Application Support/GPGTools"

    runHook postInstall
  '';
  dontFixup = true;
}
