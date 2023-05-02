{ stdenv
, lib
, fetchurl
, unzip
, makeWrapper
}:

let
  vars = {
    aarch64-darwin = rec {
      arch = "darwin-arm64";
      hash = "e4db6ebf7c777db9433a50383ab83c17c141d7e5248c683f32f21b216178cca3";
      live = "https://update.code.visualstudio.com/api/update/${arch}/stable/VERSION";
      version = "1.76.2";
    };
    universal-darwin = rec {
      arch = "darwin-universal";
      hash = "caf07f0469271a1704f893fe6a5ae85e4f0ef612e7b6283f89a80e20583dfb60";
      live = "https://update.code.visualstudio.com/api/update/${arch}/stable/VERSION";
      version = "1.76.2";
    };
    x86_64-darwin = rec {
      arch = "darwin";
      hash = "68a73ba9a6b223de4e2f20d92aaf03b2ce97fe0954187c5c4d97a69a507556e0";
      live = "https://update.code.visualstudio.com/api/update/${arch}/stable/VERSION";
      version = "1.76.2";
    };
  }.${stdenv.hostPlatform.system};
in

stdenv.mkDerivation rec {
  nativeBuildInputs = [
    unzip
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
    homepage = "https://code.visualstudio.com";
    downloadPage = "https://code.visualstudio.com/Download";
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

  pname = "visual-studio-code";
  version = vars.version;
  src = fetchurl {
    url = "https://update.code.visualstudio.com/${vars.version}/${vars.arch}/stable";
    sha256 = "${vars.hash}";
  };

  unpackPhase = ''
    runHook preUnpack

    unzip '${src}'

    runHook postUnpack
  '';
  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  dontCheck = true;
  installPhase = ''
    runHook preInstall

    mkdir -vp "''${out}/"{'Applications','bin'}

    mv -vf './Visual Studio Code.app' "''${out}/Applications"
    makeWrapper "''${out}/Applications/Visual Studio Code.app/Contents/MacOS/Electron" "''${out}/bin/${pname}"

    for BIN in "''${out}/Applications/Visual Studio Code.app/Contents/Resources/app/bin/"*
    do
      BASENAME="$(basename "''${BIN}")"
      makeWrapper "''${BIN}" "''${out}/bin/''${BASENAME}"
    done

    runHook postInstall
  '';
  dontFixup = true;
}
