{ stdenv
, lib
, fetchurl
, undmg
, makeWrapper
}:

let
  vars = {
    aarch64-darwin = rec {
      arch = "arm64";
      hash = "sha256-UTslhXnFtXjEqUEDQ7/bazZMM1CiKTq9b6ehHwhcoRs=";
      live = "https://slack.com/ssb/download-osx";
      version = "4.32.127";
    };
    universal-darwin = rec {
      arch = "universal";
      hash = "sha256-X2X/pD+zPVs2btihXDuMEaby9vxWuZchUztonJl7grk=";
      live = "https://slack.com/ssb/download-osx";
      version = "4.32.127";
    };
    x86_64-darwin = rec {
      arch = "x64";
      hash = "sha256-Wq4bbIFNI8XQuHgZQXmGZED7IgkTQdx2+M6uw943qkw=";
      live = "https://slack.com/ssb/download-osx";
      version = "4.32.127";
    };
  }.${stdenv.hostPlatform.system};
in

stdenv.mkDerivation rec {
  nativeBuildInputs = [
    undmg
    makeWrapper
  ];
  meta = with lib; {
    description = "Made for people. Built for productivity.";
    longDescription = ''
      Connect the right people, find anything you need and automate the rest.
      That's work in Slack, your productivity platform.
    '';
    homepage = "https://slack.com";
    downloadPage = "https://slack.com/downloads";
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

  pname = "slack";
  version = vars.version;
  src = fetchurl {
    url = "https://downloads.slack-edge.com/releases/macos/${vars.version}/prod/${vars.arch}/Slack-${vars.version}-macOS.dmg";
    sha256 = vars.hash;
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

    mv -vf './Slack.app' "''${out}/Applications"
    makeWrapper "''${out}/Applications/Slack.app/Contents/MacOS/Slack" "''${out}/bin/${pname}"

    runHook postInstall
  '';
  dontFixup = true;
}
