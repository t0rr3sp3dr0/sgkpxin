{ pkgs ? import <nixpkgs> { }
, latestOnly ? false
}:

let
  readOr = path: default:
    if ( builtins.pathExists path ) then ( builtins.readFile path ) else ( default );

  versAS = package:
    builtins.fromJSON ( readOr ./pkgs/${ package }/vers.json "{}" );

  pkgsAt = gitRev:
    let
      gitURL = "https://github.com/t0rr3sp3dr0/sgkpxin.git";
    in
      import ( builtins.fetchGit { url = gitURL; rev = gitRev; } ) { inherit pkgs; };

  pinVer = package: ver: rev:
    {
      name = "${ package }_${ ver }";
      value = ( pkgsAt rev ).${ package };
    };

  pinVerSet = package:
    if ( latestOnly ) then ( [ ] ) else ( pkgs.lib.attrsets.mapAttrsToList ( pinVer package ) ( versAS package ) );

  curVer = package:
    {
      name = package;
      value = pkgs.callPackage ./pkgs/${ package } { stdenv = pkgs.stdenvNoCC; };
    };

  verSet = package:
    [ ( curVer package ) ] ++ ( pinVerSet package );

  mkPackages = packages:
    pkgs.lib.pipe packages [ ( builtins.concatMap verSet ) builtins.listToAttrs ];
in

mkPackages [
  "adguard"
  "appcode"
  "aqua"
  "bitwarden"
  "clion"
  "company-portal"
  "datagrip"
  "dataspell"
  "firefox"
  "fleet"
  "goland"
  "gpg-suite"
  "intellij-idea-community-edition"
  "intellij-idea-edu"
  "intellij-idea-ultimate"
  "jetbrains-gateway"
  "jetbrains-space"
  "jetbrains-toolbox"
  "macfuse"
  "microsoft-365"
  # "microsoft-defender"
  "microsoft-edge-beta"
  "microsoft-edge-canary"
  "microsoft-edge-dev"
  "microsoft-edge-stable"
  "microsoft-excel"
  "microsoft-office-licensing-helper"
  "microsoft-onenote"
  "microsoft-outlook"
  "microsoft-powerpoint"
  "microsoft-remote-desktop"
  "microsoft-teams"
  "microsoft-word"
  "mps"
  "onedrive"
  "parallels-desktop"
  "phpstorm"
  "pycharm-community"
  "pycharm-edu"
  "pycharm-professional"
  "rider"
  "rubymine"
  "skype"
  "skype-for-business"
  "slack"
  "spotify"
  "sublime-text"
  "visual-studio"
  "visual-studio-code"
  "webstorm"
]
