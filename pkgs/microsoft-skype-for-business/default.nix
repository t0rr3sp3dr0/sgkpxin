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
    description = "Formerly Lync 2013";
    longDescription = ''
      Skype for Business, formerly Lync 2013 for iOS, extends the power of Lync
      and Skype to your favorite mobile device: voice & video over wireless,
      rich presence, instant messaging, conferencing, and calling features from
      a single, easy-to-use interface.
    '';
    homepage = "http://microsoft.com/lync";
    downloadPage = "https://microsoft.com/microsoft-365/skype-for-business/download-app";
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

  pname = "skype-for-business";
  version = vars.version;
  src = fetchurl {
    url = "https://officecdn.microsoft.com/pr/${vars.guid}/MacAutoupdate/SkypeForBusinessUpdater-${vars.version}.pkg";
    sha256 = "${vars.hash}";
  };

  unpackPhase = ''
    runHook preUnpack

    xar -vxf '${src}'

    zcat -vf "./SkypeForBusiness.pkg/Payload" | cpio -vi

    runHook postUnpack
  '';
  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  dontCheck = true;
  installPhase = ''
    runHook preInstall

    mkdir -vp "''${out}/"{'Applications/Skype for Business.app','bin'}

    mv -vf './Contents' "''${out}/Applications/Skype for Business.app"
    makeWrapper "''${out}/Applications/Skype for Business.app/Contents/MacOS/Skype for Business" "''${out}/bin/${pname}"

    runHook postInstall
  '';
  dontFixup = true;
}
