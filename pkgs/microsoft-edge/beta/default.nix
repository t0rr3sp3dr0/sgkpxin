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
    description = "The web browser from Microsoft";
    longDescription = ''
      Microsoft Edge is a browser that combines a minimal design with
      sophisticated technology to make the web faster, safer, and easier.
    '';
    homepage = "https://microsoft.com/edge";
    downloadPage = "https://microsoft.com/edge/download";
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

  pname = "microsoft-edge-beta";
  version = vars.version;
  src = fetchurl {
    url = "https://officecdnmac.microsoft.com/pr/${vars.guid}/MacAutoupdate/MicrosoftEdgeBeta-${vars.version}.pkg";
    sha256 = "${vars.hash}";
  };

  unpackPhase = ''
    runHook preUnpack

    xar -vxf '${src}'

    zcat -vf './MicrosoftEdgeBeta-${version}.pkg/Payload' | cpio -vi

    runHook postUnpack
  '';
  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  dontCheck = true;
  installPhase = ''
    runHook preInstall

    mkdir -vp "''${out}/"{'Applications','bin'}

    mv -vf './Microsoft Edge Beta.app' "''${out}/Applications"
    makeWrapper "''${out}/Applications/Microsoft Edge Beta.app/Contents/MacOS/Microsoft Edge Beta" "''${out}/bin/${pname}"

    runHook postInstall
  '';
  dontFixup = true;
}
