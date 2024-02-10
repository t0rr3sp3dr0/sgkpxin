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
    description = "A smart IDE for PHP and Web";
    longDescription = ''
      PhpStorm is a development environment for PHP and web projects. It
      supports all modern PHP versions, popular frameworks, and tools, as well
      as JavaScript, TypeScript, and frontend frameworks.
      
      PhpStorm provides smart code completion, on-the-fly error prevention,
      refactorings, and zero-configuration debugging.
      
      It is also fully equipped with DB tools, Git, GitHub pull requests, a
      terminal, Docker, and many other tools. Everything you need is just one
      click away and works seamlessly.
      
      Supported languages and technologies
      - PHP 5.3 — PHP 8.0
      - Composer, Xdebug, PHPUnit, Codeception, PHP_CodeSniffer, PHP CS Fixer,
      PHPStan, Psalm
      - Symfony, Laravel, Laminas, Twig, Blade, WordPress, Drupal, Joomla!
      - JavaScript, TypeScript, HTML, CSS, Vue, React, Angular, Node.js
      - Database tools, MySQL, PostgreSQL
      - Git, GitHub, Docker
    '';
    homepage = "https://jetbrains.com/phpstorm/";
    downloadPage = "https://jetbrains.com/phpstorm/download/#section=mac";
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

  pname = "phpstorm";
  version = vars.version;
  src = fetchurl {
    url = "https://download.jetbrains.com/webide/PhpStorm-${vars.version}${vars.variant}.dmg";
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

    mv -vf './PhpStorm.app' "''${out}/Applications"
    makeWrapper "''${out}/Applications/PhpStorm.app/Contents/MacOS/phpstorm" "''${out}/bin/${pname}"

    runHook postInstall
  '';
  dontFixup = true;
}
