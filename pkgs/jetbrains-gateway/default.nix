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
    description = "A remote development hub";
    longDescription = ''
      Gateway is an application that enables remote development workflows in
      JetBrains IDEs. It creates a secure connection between your local machine
      and a remote server, installs the IDE as a remote service and manages the
      connection to the local thin client, allowing you to work with your remote
      project with a familiar JetBrains IDE experience.
      
      You can use Gateway as a standalone launcher or as an entry point from
      your IDE to connect to a remote server.
      
      Gateway can be connected to any remote machine, physical or cloud, on the
      Linux platform.
      
      Supported IDEs
      IntelliJ IDEA Ultimate, PyCharm Professional, GoLand, PhpStorm, CLion,
      WebStorm and RubyMine
    '';
    homepage = "https://jetbrains.com/remote-development/gateway/";
    downloadPage = "https://jetbrains.com/remote-development/gateway/";
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

  pname = "jetbrains-gateway";
  version = vars.version;
  src = fetchurl {
    url = "https://download.jetbrains.com/idea/gateway/JetBrainsGateway-${vars.version}${vars.variant}.dmg";
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

    mv -vf './JetBrains Gateway.app' "''${out}/Applications"
    makeWrapper "''${out}/Applications/JetBrains Gateway.app/Contents/MacOS/gateway" "''${out}/bin/${pname}"

    runHook postInstall
  '';
  dontFixup = true;
}
