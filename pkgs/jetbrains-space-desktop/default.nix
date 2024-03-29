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
    description = "A complete software development platform";
    longDescription = ''
      Space is a unified platform that covers the entire software development
      pipeline, from hosting Git repositories, automating CI/CD, publishing
      packages, and orchestrating cloud dev environments, to managing issues,
      sharing documents, and communicating in chats - all in one place.
      
      Desktop App
      Use Space chats and receive desktop notifications while working in your
      browser. Alternatively, you can use the Desktop app instead of the web
      version, as they provide the same functionality. You'll need to create a
      Space organization first to start using the Space Desktop app.
      
      IDE integration
      With the first-class integration with IntelliJ-based IDEs, you can
      perform advanced Space code reviews, clone your Git repositories hosted
      in Space, and track your automation job's progress all in your IDE.
    '';
    homepage = "https://jetbrains.com/help/space/space-desktop-app.html";
    downloadPage = "https://jetbrains.com/help/space/space-desktop-app.html#to-install-the-desktop-app";
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

  pname = "jetbrains-space";
  version = vars.version;
  src = fetchurl {
    url = "https://download.jetbrains.com/space/jetbrains-space-${vars.version}${vars.variant}.dmg";
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

    mv -vf './JetBrains Space.app' "''${out}/Applications"
    makeWrapper "''${out}/Applications/JetBrains Space.app/Contents/MacOS/JetBrains Space" "''${out}/bin/${pname}"

    runHook postInstall
  '';
  dontFixup = true;
}
