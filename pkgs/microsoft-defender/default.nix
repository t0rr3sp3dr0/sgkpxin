{ stdenv
, lib
, fetchurl
, xar
, cpio
, makeWrapper
}:

let
  data = builtins.fromJSON ( builtins.readFile ./vars.json );
  plat = stdenv.hostPlatform.system;
  vars = data.${plat} or ( data.universal-darwin or ( data.x86_64-darwin or ( throw "${plat} is not supported" )));
in

stdenv.mkDerivation rec {
  nativeBuildInputs = [
    xar
    cpio
    makeWrapper
  ];
  meta = with lib; {
    description = "Protect. Control. Defend.";
    longDescription = ''
      Microsoft Defender is a unified online security app for your work and
      personal life. Use Microsoft Defender for individuals (1) at home and on
      the go. For work, Microsoft Defender for Endpoint helps organizations
      around the world stay more secure.
    '';
    homepage = "https://microsoft.com/defender";
    downloadPage = "https://support.microsoft.com/topic/029d8bc0-637d-4d5b-be94-52a71f7848fb";
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

  pname = "microsoft-defender";
  version = vars.version;
  src = fetchurl {
    url = "https://officecdn.microsoft.com/pr/${vars.guid}/MacAutoupdate/wdav-${vars.version}.pkg";
    sha256 = "${vars.hash}";
  };

  unpackPhase = ''
    runHook preUnpack

    xar -vxf '${src}'

    # zcat -vf "./MAU.pkg/Payload" | cpio -vi

    zcat -vf "./dlp-agent.pkg/Payload" | cpio -vi
    zcat -vf "./dlp-daemon.pkg/Payload" | cpio -vi
    zcat -vf "./dlp-ux.pkg/Payload" | cpio -vi

    zcat -vf "./wdav-pkg.pkg/Payload" | cpio -vi

    runHook postUnpack
  '';
  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  dontCheck = true;
  installPhase = ''
    runHook preInstall

    mkdir -vp "''${out}/"{'Applications','Library/Application Support/Microsoft/DLP','bin'}

    mv -vf './com.microsoft.dlp.agent.app' "''${out}/Library/Application Support/Microsoft/DLP"
    mv -vf './com.microsoft.dlp.daemon.app' "''${out}/Library/Application Support/Microsoft/DLP"
    mv -vf './com.microsoft.dlp.ux.app' "''${out}/Library/Application Support/Microsoft/DLP"

    mv -vf './Microsoft Defender.app' "''${out}/Applications"
    makeWrapper "''${out}/Applications/Microsoft Defender.app/Contents/MacOS/wdavdaemon" "''${out}/bin/${pname}"

    runHook postInstall
  '';
  dontFixup = true;
}
