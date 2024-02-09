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
    description = "Protect and access your files";
    longDescription = ''
      Start with 5 GB of free cloud storage or upgrade to a Microsoft 365
      subscription to get 1 TB of storage. Microsoft 365 includes premium Office
      apps, 1 TB cloud storage in OneDrive, advanced security, and more, all in
      one convenient subscription. With Microsoft 365, you get features as soon
      as they are released ensuring you're always working with the latest.
    '';
    homepage = "https://microsoft.com/microsoft-365/onedrive";
    downloadPage = "https://microsoft.com/microsoft-365/onedrive/download";
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

  pname = "onedrive";
  version = vars.version;
  src = fetchurl {
    url = "https://oneclient.sfx.ms/Mac/Installers/${vars.version}${if vars.variant == "" then "" else "/${lib.strings.toLower vars.variant}"}/OneDrive.pkg";
    sha256 = "${vars.hash}";
  };

  unpackPhase = ''
    runHook preUnpack

    xar -vxf '${src}'

    zcat -vf "./OneDrive.pkg/Payload" | cpio -vi

    runHook postUnpack
  '';
  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  dontCheck = true;
  installPhase = ''
    runHook preInstall

    mkdir -vp "''${out}/"{'Applications','bin'}

    mv -vf './OneDrive.app' "''${out}/Applications"
    makeWrapper "''${out}/Applications/OneDrive.app/Contents/MacOS/OneDrive" "''${out}/bin/${pname}"

    runHook postInstall
  '';
  dontFixup = true;
}
