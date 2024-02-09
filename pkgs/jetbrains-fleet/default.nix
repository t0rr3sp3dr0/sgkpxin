{ stdenv
, lib
, fetchurl
, undmg
, makeWrapper
}:

let
  data = builtins.fromJSON ( builtins.readFile ./vars.json );
  plat = stdenv.hostPlatform.system;
  vars = data.${plat} or ( data.universal-darwin or ( data.x86_64-darwin or ( throw "${plat} is not supported" )));
in

stdenv.mkDerivation rec {
  nativeBuildInputs = [
    undmg
    makeWrapper
  ];
  meta = with lib; {
    description = "The next-generation IDE by JetBrains";
    longDescription = ''
      Fleet is both an IDE and a lightweight code editor. With a single click it
      can transform from one to another. As an editor for a small task, Fleet
      will start in a second, ready for you to work in. When you need more
      advanced features, Fleet's smart mode with IntelliJ code-processing
      activated is one click away, supporting a wide range of languages and
      technologies.
      
      Collaboration scenarios are at users' fingertips allowing them to easily
      invite colleagues to explore, edit and debug code together, perform code
      reviews and work together in general.
      
      Fleet is also designed to enable a variety of remote development
      scenarios. Users can simply run Fleet on their machine, or move some of
      the processes elsewhere, for example run the code processing on the cloud.
      
      Supported languages and technologies
      Python, Java, JavaScript, C#, PHP, TypeScript, Go, Kotlin, Rust
    '';
    homepage = "https://jetbrains.com/fleet/";
    downloadPage = "https://jetbrains.com/fleet/download/#section=mac";
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

  pname = "fleet";
  version = vars.version;
  src = fetchurl {
    url = "https://download-cdn.jetbrains.com/fleet/installers/macos_${vars.variant}/Fleet-${vars.version}${if vars.variant == "x64" then "" else "-${vars.variant}"}.dmg";
    hash = vars.hash;
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

    mv -vf './Fleet.app' "''${out}/Applications"
    makeWrapper "''${out}/Applications/Fleet.app/Contents/MacOS/Fleet" "''${out}/bin/${pname}"

    runHook postInstall
  '';
  dontFixup = true;
}
