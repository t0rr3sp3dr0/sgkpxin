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
    description = "The IDE for databases and SQL";
    longDescription = ''
      DataGrip is a multi-engine database environment. Targeting the needs of
      professional SQL developers, DataGrip makes working with databases an
      enjoyable experience.

      Supported languages and technologies
      Oracle, PostgreSQL, MySQL, MariaDb, Microsoft SQL Server, Microsoft Azure,
      DB2, Sybase, SQLite, HyperSQL, Apache Derby, H2, Exasol, Amazon Redshift,
      Snowflake, Apache Hive, Google BigQuery, Vertica, Cassandra, ClickHouse,
      MongoDB, Couchbase, CockroachDb
    '';
    homepage = "https://jetbrains.com/datagrip/";
    downloadPage = "https://jetbrains.com/datagrip/download/#section=mac";
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

  pname = "datagrip";
  version = vars.version;
  src = fetchurl {
    url = "https://download-cdn.jetbrains.com/datagrip/datagrip-${vars.version}${vars.variant}.dmg";
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

    mv -vf './DataGrip.app' "''${out}/Applications"
    makeWrapper "''${out}/Applications/DataGrip.app/Contents/MacOS/datagrip" "''${out}/bin/${pname}"

    runHook postInstall
  '';
  dontFixup = true;
}
