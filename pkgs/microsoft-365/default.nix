{ stdenv
, lib
, fetchurl
, xar
, cpio
, envsubst
, makeWrapper
}:

let
  vars = {
    guid = "C1297A47-86C4-4C1F-97FA-950631F94777";
    hash = "4298d9dacce0c30f9979f389140e84639831322da57415d2afba3fc7a36909c2";
    live = "https://go.microsoft.com/fwlink/?linkid=2158744";
  };

  molhLabel = "com.microsoft.office.licensingV2.helper";
  molhAppleScript = ''
    #!/usr/bin/osascript

    repeat with v in {"Excel", "OneNote", "Outlook", "PowerPoint", "Word"}
      tell application ("Microsoft " & v) to if running then quit
    end repeat

    try
      alias "Macintosh HD:Library:PrivilegedHelperTools:${molhLabel}"
    on error number -1728
      do shell script "touch '/Library/PrivilegedHelperTools/${molhLabel}' 2>&1" with administrator privileges without altering line endings
    end try

    try
      do shell script "launchctl bootout \"gui/$(id -u)/${molhLabel}\" 2>&1" without altering line endings
    on error number 3
    end try

    do shell script "launchctl load -w ''\'''${out}/Library/LaunchAgents/${molhLabel}.plist' 2>&1" without altering line endings
  '';
in

stdenv.mkDerivation rec {
  nativeBuildInputs = [
    xar
    cpio
    envsubst
    makeWrapper
  ];
  meta = with lib; {
    description = "Word, Excel, PowerPoint & More";
    longDescription = ''
      Microsoft 365 is the ultimate everyday productivity app that helps you
      create, edit, and share on the go. With Word, Excel, and PowerPoint all in
      one app, Microsoft 365 is the destination for creating and editing
      documents on the fly when you need them most.
    '';
    homepage = "https://microsoft.com/office";
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

  pname = "microsoft-365";
  version = "16.70.23021201";
  src = fetchurl {
    url = "https://officecdn.microsoft.com/pr/${vars.guid}/MacAutoupdate/Microsoft_365_and_Office_${version}_BusinessPro_Installer.pkg";
    sha256 = "${vars.hash}";
  };

  unpackPhase = ''
    runHook preUnpack

    xar -vxf '${src}'

    for APP in Excel OneNote Outlook PowerPoint Word
    do
      zcat -vf "./Microsoft_''${APP}_Internal.pkg/Payload" | cpio -vi
    done

    zcat -vf './OneDrive.pkg/Payload' | cpio -vi

    zcat -vf './Office_fonts.pkg/Payload' | cpio -vi
    zcat -vf './Office_frameworks.pkg/Payload' | cpio -vi
    zcat -vf './Office_proofing.pkg/Payload' | cpio -vi

    # zcat -vf './Office16_all_autoupdate.pkg/Payload' | cpio -vi

    zcat -vf './Office16_all_licensing.pkg/Payload' | cpio -vi

    zcat -vf "./Teams_osx_app.pkg/Payload" | cpio -vi

    runHook postUnpack
  '';
  patchPhase = ''
    runHook prePatch

    for APP in Excel OneNote Outlook PowerPoint Word
    do
      mkdir -vp "./Microsoft ''${APP}.app/Contents/"{'Frameworks','Resources/DFonts','SharedSupport/Proofing Tools'}

      for FONT in './DFonts/'*
      do
        BASENAME="$(basename "''${FONT}")"
        ln -vfs "''${out}/Library/Fonts/''${BASENAME}" "./Microsoft ''${APP}.app/Contents/Resources/DFonts"
      done

      for FRAMEWORK in './Frameworks/'*
      do
        BASENAME="$(basename "''${FRAMEWORK}")"
        ln -vfs "''${out}/Library/Frameworks/''${BASENAME}" "./Microsoft ''${APP}.app/Contents/Frameworks"
      done

      for PROOFING_TOOL in './Proofing Tools/'*
      do
        BASENAME="$(basename "''${PROOFING_TOOL}")"
        ln -vfs "''${out}/Library/Application Support/com.microsoft.office.proofing/''${BASENAME}" "./Microsoft ''${APP}.app/Contents/SharedSupport/Proofing Tools"
      done
    done

    substituteInPlace './Library/LaunchDaemons/'* --replace '>/' ">''${out}/"
    mv -vf './Library/Launch'{'Daemons','Agents'}

    runHook postPatch
  '';
  dontConfigure = true;
  buildPhase = ''
    runHook preBuild

    envsubst <<< "''${molhAppleScript}" > './microsoft-office-licensing-helper'
    chmod +x './microsoft-office-licensing-helper'

    runHook postBuild
  '';
  dontCheck = true;
  installPhase = ''
    runHook preInstall

    mkdir -vp "''${out}/"{'Applications','Library/'{'Application Support/com.microsoft.office.proofing','Fonts','Frameworks','LaunchAgents','PrivilegedHelperTools'},'bin'}

    for APP in Excel OneNote Outlook PowerPoint Word
    do
      mv -vf "./Microsoft ''${APP}.app" "''${out}/Applications"
      makeWrapper "''${out}/Applications/Microsoft ''${APP}.app/Contents/MacOS/Microsoft ''${APP}" "''${out}/bin/microsoft-$(awk '{ print tolower($0); }' <<< "''${APP}")"
    done

    mv -vf './OneDrive.app' "''${out}/Applications"
    makeWrapper "''${out}/Applications/OneDrive.app/Contents/MacOS/OneDrive" "''${out}/bin/onedrive"

    mv -vf './DFonts/'* "''${out}/Library/Fonts"
    mv -vf './Frameworks/'* "''${out}/Library/Frameworks"
    mv -vf './Proofing Tools/'* "''${out}/Library/Application Support/com.microsoft.office.proofing"

    cp -vf './Library/LaunchAgents/'* "''${out}/Library/LaunchAgents"
    cp -vf './Library/PrivilegedHelperTools/'* "''${out}/Library/PrivilegedHelperTools"
    cp -vf './microsoft-office-licensing-helper' "''${out}/bin"

    mv -vf './Microsoft Teams.app' "''${out}/Applications"
    makeWrapper "''${out}/Applications/Microsoft Teams.app/Contents/MacOS/Teams" "''${out}/bin/microsoft-teams"

    runHook postInstall
  '';
  dontFixup = true;

  inherit molhAppleScript;
}
