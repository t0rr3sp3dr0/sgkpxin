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
  "jetbrains-appcode"
  "jetbrains-gateway"
  "jetbrains-intellij-idea"
  "jetbrains-pycharm"
  "jetbrains-space"
  "jetbrains-toolbox"
  "macfuse"
  "microsoft-365"
  # "microsoft-defender"
  "microsoft-edge"
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
