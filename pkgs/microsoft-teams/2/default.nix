{ stdenv
, lib
, fetchurl
, xar
, cpio
, pbzx
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
    pbzx
    makeWrapper
  ];
  meta = with lib; {
    description = "Protect and access your files";
    longDescription = ''
      Whether you're connecting with your community for an upcoming activity or
      working with teammates on a project, Microsoft Teams helps bring people
      together so that they can get things done. It's the only app that has
      communities, events, chats, channels, meetings, storage, tasks, and
      calendars in one place—so you can easily connect and manage access to
      information. Get your community, family, friends, or workmates together to
      accomplish tasks, share ideas, and make plans. Join audio and video calls
      in a secure setting, collaborate in documents, and store files and photos
      with built-in cloud storage. You can do it all in Microsoft Teams.
    '';
    homepage = "https://microsoft.com/microsoft-teams";
    downloadPage = "https://microsoft.com/microsoft-teams/download-app";
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

  pname = "microsoft-teams";
  version = vars.version;
  src = fetchurl {
    url = "https://statics.teams.cdn.office.net/production-osx/${vars.version}/MicrosoftTeams.pkg";
    sha256 = "${vars.hash}";
  };

  unpackPhase = ''
    runHook preUnpack

    xar -vxf '${src}'

    zcat -vf './MSTeamsAudioDevice.pkg/Payload' | cpio -vi

    pbzx -n './MicrosoftTeams_app.pkg/Payload' | cpio -vi

    runHook postUnpack
  '';
  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  dontCheck = true;
  installPhase = ''
    runHook preInstall

    mkdir -vp "''${out}/"{'Applications','Library/Audio/Plug-Ins/HAL','bin'}

    mv -vf './MSTeamsAudioDevice.driver' "''${out}/Library/Audio/Plug-Ins/HAL"

    mv -vf './Microsoft Teams.app' "''${out}/Applications"
    makeWrapper "''${out}/Applications/Microsoft Teams.app/Contents/MacOS/MSTeams" "''${out}/bin/${pname}"

    runHook postInstall
  '';
  dontFixup = true;
}
