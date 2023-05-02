{ stdenv
, lib
, fetchurl
, undmg
, makeWrapper
}:

let
  vars = {
    hash = "16901b4106a921c67b1ac1a31f865e27cd4a7be35417b1af815d701032caa145";
    live = "https://update.parallels.com/desktop/v18/parallels/parallels_sbscr_updates.xml";
  };
in

stdenv.mkDerivation rec {
  nativeBuildInputs = [
    undmg
    makeWrapper
  ];
  meta = with lib; {
    description = "Run Windows applications";
    longDescription = ''
      Parallels Desktop® App Store Edition is a fast, easy and powerful
      application for running Windows both on a Mac with Apple M-series chips
      and a Mac with an Intel processor - all without rebooting.
    '';
    homepage = "https://parallels.com/products/desktop/";
    downloadPage = "https://parallels.com/products/desktop/download/";
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

  pname = "parallels-desktop";
  version = "18.2.0-53488";
  src = fetchurl {
    url = "https://download.parallels.com/desktop/v${lib.versions.major version}/${version}/ParallelsDesktop-${version}.dmg";
    sha256 = "${vars.hash}";
  };

  unpackPhase = ''
    runHook preUnpack

    undmg '${src}'

    runHook postUnpack
  '';
  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  dontCheck = true;
  installPhase = ''
    runHook preInstall

    mkdir -vp "''${out}/"{'Applications','bin'}

    mv -vf './Parallels Desktop.app' "''${out}/Applications"
    makeWrapper "''${out}/Applications/Parallels Desktop.app/Contents/MacOS/prl_client_app" "''${out}/bin/${pname}"

    runHook postInstall
  '';
  dontFixup = true;
}
