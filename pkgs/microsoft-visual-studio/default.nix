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
    description = "Code editing. Redefined.";
    longDescription = ''
      Visual Studio Code is a lightweight but powerful source code editor which
      runs on your desktop and is available for Windows, macOS and Linux. It
      comes with built-in support for JavaScript, TypeScript and Node.js and has
      a rich ecosystem of extensions for other languages and runtimes (such as
      C++, C#, Java, Python, PHP, Go, .NET).
    '';
    homepage = "https://visualstudio.microsoft.com/vs/mac/";
    downloadPage = "https://visualstudio.microsoft.com/downloads/";
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

  pname = "visual-studio";
  version = vars.version;
  src = fetchurl {
    url = "https://download.visualstudio.microsoft.com/download/pr/${vars.uuid}/${vars.guid}/visualstudioformac-${vars.version}-${vars.variant}.dmg";
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

    mv -vf './Visual Studio.app' "''${out}/Applications"
    makeWrapper "''${out}/Applications/Visual Studio.app/Contents/MacOS/VisualStudio" "''${out}/bin/${pname}"

    runHook postInstall
  '';
  dontFixup = true;
}
