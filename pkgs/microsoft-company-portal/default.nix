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
    description = "Company resources on the go";
    longDescription = ''
      Microsoft Intune helps organizations manage access to corporate apps,
      data, and resources. Company Portal is the app that lets you, as an
      employee of your company, securely access those resources.
    '';
    homepage = "https://learn.microsoft.com/en-ca/mem/intune/user-help/use-managed-devices-to-get-work-done";
    downloadPage = "https://learn.microsoft.com/mem/intune/user-help/enroll-your-device-in-intune-macos-cp#install-company-portal-app";
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

  pname = "company-portal";
  version = vars.version;
  src = fetchurl {
    url = "https://officecdn.microsoft.com/pr/${vars.guid}/MacAutoupdate/CompanyPortal_${vars.version}-Upgrade.pkg";
    sha256 = "${vars.hash}";
  };

  unpackPhase = ''
    runHook preUnpack

    xar -vxf '${src}'

    zcat -vf './CompanyPortal-Component.pkg/Payload' | cpio -vi

    runHook postUnpack
  '';
  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  dontCheck = true;
  installPhase = ''
    runHook preInstall

    mkdir -vp "''${out}/"{'Applications','bin'}

    mv -vf './Applications/Company Portal.app' "''${out}/Applications"
    makeWrapper "''${out}/Applications/Company Portal.app/Contents/MacOS/Company Portal" "''${out}/bin/company-portal"

    runHook postInstall
  '';
  dontFixup = true;
}
