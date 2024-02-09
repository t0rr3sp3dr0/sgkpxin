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
    description = "A cross-platform .NET IDE";
    longDescription = ''
      JetBrains Rider is a cross-platform .NET IDE based on the IntelliJ
      Platform and ReSharper. It helps you develop .NET, ASP.NET, .NET Core,
      Xamarin, and Unity applications on Windows, macOS, or Linux. Despite a
      heavy feature set, Rider is designed to be fast and responsive.
      
      Supported languages and technologies
      .NET, .NET Core, ASP.NET, ASP.NET Core, C#, VB.NET, F#, Razor, Blazor,
      Xamarin, Unity, HLSL, AWS, Azure, JavaScript, TypeScript, XAML, XML,
      HTML, CSS, SCSS, JSON, and SQL
    '';
    homepage = "https://jetbrains.com/rider/";
    downloadPage = "https://jetbrains.com/rider/download/#section=mac";
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

  pname = "rider";
  version = vars.version;
  src = fetchurl {
    url = "https://download-cdn.jetbrains.com/rider/JetBrains.Rider-${vars.version}${vars.variant}.dmg";
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

    mv -vf './Rider.app' "''${out}/Applications"
    makeWrapper "''${out}/Applications/Rider.app/Contents/MacOS/rider" "''${out}/bin/${pname}"

    runHook postInstall
  '';
  dontFixup = true;
}
