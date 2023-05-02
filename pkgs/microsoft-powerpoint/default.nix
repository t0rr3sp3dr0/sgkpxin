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
    description = "Design Slideshow Presentations";
    longDescription = ''
      The PowerPoint app gives you access to the familiar slideshow maker tool
      you already know. Create, edit, view, present, or share presentations
      quickly and easily from anywhere.
    '';
    homepage = "https://microsoft.com/office/powerpoint";
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

  pname = "microsoft-powerpoint";
  version = vars.version;
  src = fetchurl {
    url = "https://officecdn.microsoft.com/pr/${vars.guid}/MacAutoupdate/Microsoft_PowerPoint_${vars.version}_Updater.pkg";
    sha256 = "${vars.hash}";
  };

  unpackPhase = ''
    runHook preUnpack

    xar -vxf '${src}'

    zcat -vf "./Microsoft_PowerPoint.pkg/Payload" | cpio -vi

    runHook postUnpack
  '';
  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  dontCheck = true;
  installPhase = ''
    runHook preInstall

    mkdir -vp "''${out}/"{'Applications','bin'}

    mv -vf './Microsoft PowerPoint.app' "''${out}/Applications"
    makeWrapper "''${out}/Applications/Microsoft PowerPoint.app/Contents/MacOS/Microsoft PowerPoint" "''${out}/bin/${pname}"

    runHook postInstall
  '';
  dontFixup = true;
}
