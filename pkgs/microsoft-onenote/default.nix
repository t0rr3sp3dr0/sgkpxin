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
    description = "Capture Notes, Ideas and Memos";
    longDescription = ''
      Capture your thoughts, discoveries, and ideas and simplify overwhelming
      planning moments in your life with your very own digital notepad.
    '';
    homepage = "https://microsoft.com/onenote";
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

  pname = "microsoft-onenote";
  version = vars.version;
  src = fetchurl {
    url = "https://officecdn.microsoft.com/pr/${vars.guid}/MacAutoupdate/Microsoft_OneNote_${vars.version}_Updater.pkg";
    sha256 = "${vars.hash}";
  };

  unpackPhase = ''
    runHook preUnpack

    xar -vxf '${src}'

    zcat -vf "./Microsoft_OneNote.pkg/Payload" | cpio -vi

    runHook postUnpack
  '';
  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  dontCheck = true;
  installPhase = ''
    runHook preInstall

    mkdir -vp "''${out}/"{'Applications','bin'}

    mv -vf './Microsoft OneNote.app' "''${out}/Applications"
    makeWrapper "''${out}/Applications/Microsoft OneNote.app/Contents/MacOS/Microsoft OneNote" "''${out}/bin/${pname}"

    runHook postInstall
  '';
  dontFixup = true;
}
