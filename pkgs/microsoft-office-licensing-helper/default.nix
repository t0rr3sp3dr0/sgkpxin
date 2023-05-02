{ stdenv
, lib
, fetchurl
, xar
, cpio
, envsubst
, makeWrapper
}:

let
  data = builtins.fromJSON ( builtins.readFile ./vars.json );
  plat = stdenv.hostPlatform.system;
  vars = data.${plat} or ( data.universal-darwin or ( data.x86_64-darwin or ( throw "${plat} is not supported" )));

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
    description = "Activate Office for Mac";
    longDescription = ''
      Office for Mac uses a helper tool to provide device-wide activation for
      perpetual licenses, such as Office Home & Business 2021.
    '';
    homepage = "https://learn.microsoft.com/deployoffice/mac/overview-of-activation-for-office-for-mac";
    downloadPage = "https://learn.microsoft.com/en-us/deployoffice/mac/licensing-helper-tool";
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

  pname = "microsoft-office-licensing-helper";
  version = vars.version;
  src = fetchurl {
    url = "https://officecdn.microsoft.com/pr/${vars.guid}/MacAutoupdate/Microsoft_OfficeLicensingHelper_${vars.version}_Updater.pkg";
    sha256 = "${vars.hash}";
  };

  unpackPhase = ''
    runHook preUnpack

    xar -vxf '${src}'

    zcat -vf './Microsoft_OfficeLicensingHelper_Updater.pkg/Payload' | cpio -vi

    runHook postUnpack
  '';
  patchPhase = ''
    runHook prePatch

    substituteInPlace './${molhLabel}.plist' --replace '>/' ">''${out}/"

    runHook postPatch
  '';
  dontConfigure = true;
  buildPhase = ''
    runHook preBuild

    envsubst <<< "''${molhAppleScript}" > './${pname}'
    chmod +x './${pname}'

    runHook postBuild
  '';
  dontCheck = true;
  installPhase = ''
    runHook preInstall

    mkdir -vp "''${out}/"{'Library/'{'LaunchAgents','PrivilegedHelperTools'},'bin'}

    cp -vf './${molhLabel}' "''${out}/Library/PrivilegedHelperTools"
    cp -vf './${molhLabel}.plist' "''${out}/Library/LaunchAgents"
    cp -vf './${pname}' "''${out}/bin"

    runHook postInstall
  '';
  dontFixup = true;

  inherit molhAppleScript;
}
