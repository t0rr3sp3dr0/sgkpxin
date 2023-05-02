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
    description = "Organize Your Data and Budget";
    longDescription = ''
      Microsoft Excel, the spreadsheet app, lets you create, view, edit, and
      share your files quickly and easily. Manage spreadsheets, tables and
      workbooks attached to email messages from your phone with this powerful
      productivity app.
    '';
    homepage = "https://microsoft.com/office/excel";
    downloadPage = "https://aka.ms/office-install";
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

  pname = "microsoft-excel";
  version = vars.version;
  src = fetchurl {
    url = "https://officecdn.microsoft.com/pr/${vars.guid}/MacAutoupdate/Microsoft_Excel_${vars.version}_Updater.pkg";
    sha256 = "${vars.hash}";
  };

  unpackPhase = ''
    runHook preUnpack

    xar -vxf '${src}'

    zcat -vf "./Microsoft_Excel.pkg/Payload" | cpio -vi

    runHook postUnpack
  '';
  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  dontCheck = true;
  installPhase = ''
    runHook preInstall

    mkdir -vp "''${out}/"{'Applications','bin'}

    mv -vf './Microsoft Excel.app' "''${out}/Applications"
    makeWrapper "''${out}/Applications/Microsoft Excel.app/Contents/MacOS/Microsoft Excel" "''${out}/bin/${pname}"

    runHook postInstall
  '';
  dontFixup = true;
}
