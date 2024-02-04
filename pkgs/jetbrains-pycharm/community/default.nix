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
    description = "The pure Python IDE";
    longDescription = ''
      PyCharm is an integrated development environment that provides a wide
      range of tools for productive Python, web, and data science development,
      including code inspections, visual debugging, package management, virtual
      environment management, refactorings, test runners, version control
      integration, and more.
      
      Supported languages and technologies
      Python, Cython, Jupyter, HTML, Git, GitHub, Mercurial, Subversion, Conda
      integration
    '';
    homepage = "https://jetbrains.com/pycharm/";
    downloadPage = "https://jetbrains.com/pycharm/download/#section=mac";
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

  pname = "pycharm-community";
  version = vars.version;
  src = fetchurl {
    url = "https://download-cdn.jetbrains.com/python/pycharm-community-${vars.version}${vars.variant}.dmg";
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

    mv -vf './PyCharm CE.app' "''${out}/Applications"
    makeWrapper "''${out}/Applications/PyCharm CE.app/Contents/MacOS/pycharm" "''${out}/bin/${pname}"

    runHook postInstall
  '';
  dontFixup = true;
}
