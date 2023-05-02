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
    description = "Secure Email, Calendar & Files";
    longDescription = ''
      Outlook lets you bring all of your email accounts and calendars in one
      convenient spot. Whether it's staying on top of your inbox or scheduling
      the next big thing, we make it easy to be your most productive, organised
      and connected self.
    '';
    homepage = "https://microsoft.com/office/outlook";
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

  pname = "microsoft-outlook";
  version = vars.version;
  src = fetchurl {
    url = "https://officecdn.microsoft.com/pr/${vars.guid}/MacAutoupdate/Microsoft_Outlook_${vars.version}_Updater.pkg";
    sha256 = "${vars.hash}";
  };

  unpackPhase = ''
    runHook preUnpack

    xar -vxf '${src}'

    zcat -vf "./Microsoft_Outlook.pkg/Payload" | cpio -vi

    runHook postUnpack
  '';
  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  dontCheck = true;
  installPhase = ''
    runHook preInstall

    mkdir -vp "''${out}/"{'Applications','bin'}

    mv -vf './Microsoft Outlook.app' "''${out}/Applications"
    makeWrapper "''${out}/Applications/Microsoft Outlook.app/Contents/MacOS/Microsoft Outlook" "''${out}/bin/${pname}"

    runHook postInstall
  '';
  dontFixup = true;
}
