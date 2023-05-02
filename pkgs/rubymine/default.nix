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
    description = "A Ruby and Rails IDE";
    longDescription = ''
      RubyMine is an intelligent IDE that provides essential tools for Ruby and
      Ruby on Rails development out of the box. It helps you be more productive
      in every aspect of Ruby/Rails projects development — from writing and
      debugging code to testing and deploying a completed application.
      
      Supported languages and technologies
      Ruby, Ruby on Rails, JavaScript, TypeScript, CoffeeScript, ERB and HAML,
      CSS, Sass, Less, Git, GitHub, Docker, and more
    '';
    homepage = "https://jetbrains.com/ruby/";
    downloadPage = "https://jetbrains.com/ruby/download/#section=mac";
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

  pname = "rubymine";
  version = vars.version;
  src = fetchurl {
    url = "https://download-cdn.jetbrains.com/ruby/RubyMine-${vars.version}${vars.variant}.dmg";
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

    mv -vf './RubyMine.app' "''${out}/Applications"
    makeWrapper "''${out}/Applications/RubyMine.app/Contents/MacOS/rubymine" "''${out}/bin/${pname}"

    runHook postInstall
  '';
  dontFixup = true;
}
