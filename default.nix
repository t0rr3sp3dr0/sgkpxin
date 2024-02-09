{ pkgs ? import <nixpkgs> { }
, noVersioning ? false
, noDefaulting ? false
, ...
}:

let
  mkPackages = import ./util/mkPackages.nix { inherit pkgs noVersioning noDefaulting; };
in

mkPackages [
  "adguard"
  "bitwarden"
  "gpg-suite"
  "jetbrains-aqua"
  "jetbrains-appcode"
  "jetbrains-clion"
  "jetbrains-datagrip"
  "jetbrains-dataspell"
  "jetbrains-dotmemory"
  "jetbrains-dottrace"
  "jetbrains-fleet"
  "jetbrains-gateway"
  "jetbrains-goland"
  "jetbrains-intellij-idea"
  "jetbrains-mps"
  "jetbrains-phpstorm"
  "jetbrains-pycharm"
  "jetbrains-rider"
  "jetbrains-rubymine"
  "jetbrains-rustrover"
  "jetbrains-space-desktop"
  "jetbrains-toolbox"
  "jetbrains-webstorm"
  "jetbrains-writerside"
  "macfuse"
  "microsoft-365"
  "microsoft-company-portal"
  # "microsoft-defender"
  "microsoft-edge"
  "microsoft-excel"
  "microsoft-office-licensing-helper"
  "microsoft-onedrive"
  "microsoft-onenote"
  "microsoft-outlook"
  "microsoft-powerpoint"
  "microsoft-remote-desktop"
  "microsoft-skype"
  "microsoft-skype-for-business"
  "microsoft-teams"
  "microsoft-visual-studio"
  "microsoft-visual-studio-code"
  "microsoft-word"
  "mozilla-firefox"
  "parallels-desktop"
  "slack"
  "spotify"
  "sublime-text"
]
