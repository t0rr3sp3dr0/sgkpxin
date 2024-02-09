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
    description = "An IDE for data scientists";
    longDescription = ''
      DataSpell is an IDE for data scientists. It offers a productive developer
      environment for data science professionals who are actively involved in
      exploratory data analysis and prototyping machine learning models.
      DataSpell brings a wide range of data science tools together, including
      notebooks, interactive REPL, dataset and visualization explorer, and Conda
      support. At the same time it offers intelligent coding assistance for
      Python and tons of other tools, all integrated seamlessly under a unified
      user interface.

      Supported languages and technologies
      Python, Jupyter, R, SQL, Matplotlib, Plotly, Bokeh, TensorFlow, PyTorch,
      Conda, CSV, Parquet
    '';
    homepage = "https://jetbrains.com/dataspell/";
    downloadPage = "https://jetbrains.com/dataspell/download/#section=mac";
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

  pname = "dataspell";
  version = vars.version;
  src = fetchurl {
    url = "https://download-cdn.jetbrains.com/python/dataspell-${vars.version}${vars.variant}.dmg";
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

    mv -vf './DataSpell.app' "''${out}/Applications"
    makeWrapper "''${out}/Applications/DataSpell.app/Contents/MacOS/dataspell" "''${out}/bin/${pname}"

    runHook postInstall
  '';
  dontFixup = true;
}
