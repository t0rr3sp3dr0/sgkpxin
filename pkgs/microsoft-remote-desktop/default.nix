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
    description = "Work from anywhere";
    longDescription = ''
      Use Microsoft Remote Desktop for Mac to connect to Azure Virtual Desktop,
      Windows 365, admin-provided virtual apps and desktops, or remote PCs. With
      Microsoft Remote Desktop, you can be productive no matter where you are.
    '';
    homepage = "https://learn.microsoft.com/windows-server/remote/remote-desktop-services/clients/remote-desktop-mac";
    downloadPage = "https://learn.microsoft.com/windows-server/remote/remote-desktop-services/clients/mac-whatsnew#latest-client-versions";
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

  pname = "microsoft-remote-desktop";
  version = vars.version;
  src = fetchurl {
    url = "https://officecdn.microsoft.com/pr/${vars.guid}/MacAutoupdate/Microsoft_Remote_Desktop_${vars.version}_updater.pkg";
    sha256 = "${vars.hash}";
  };

  unpackPhase = ''
    runHook preUnpack

    xar -vxf '${src}'

    zcat -vf "./com.microsoft.rdc.macos.pkg/Payload" | cpio -vi

    runHook postUnpack
  '';
  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  dontCheck = true;
  installPhase = ''
    runHook preInstall

    mkdir -vp "''${out}/"{'Applications','bin'}

    mv -vf './Microsoft Remote Desktop.app' "''${out}/Applications"
    makeWrapper "''${out}/Applications/Microsoft Remote Desktop.app/Contents/MacOS/Microsoft Remote Desktop" "''${out}/bin/${pname}"

    runHook postInstall
  '';
  dontFixup = true;
}
