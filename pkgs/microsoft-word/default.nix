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
    description = "Create a Resume, Essay or PDF";
    longDescription = ''
      The trusted Word app lets you create, edit, view, and share your files
      with others quickly and easily. Send, view and edit Office docs attached
      to emails from your phone with this powerful word processing app from
      Microsoft.
    '';
    homepage = "https://microsoft.com/office/word";
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

  pname = "microsoft-word";
  version = vars.version;
  src = fetchurl {
    url = "https://officecdn.microsoft.com/pr/${vars.guid}/MacAutoupdate/Microsoft_Word_${vars.version}_Updater.pkg";
    sha256 = "${vars.hash}";
  };

  unpackPhase = ''
    runHook preUnpack

    xar -vxf '${src}'

    zcat -vf "./Microsoft_Word.pkg/Payload" | cpio -vi

    runHook postUnpack
  '';
  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  dontCheck = true;
  installPhase = ''
    runHook preInstall

    mkdir -vp "''${out}/"{'Applications','bin'}

    mv -vf './Microsoft Word.app' "''${out}/Applications"
    makeWrapper "''${out}/Applications/Microsoft Word.app/Contents/MacOS/Microsoft Word" "''${out}/bin/${pname}"

    runHook postInstall
  '';
  dontFixup = true;
}
