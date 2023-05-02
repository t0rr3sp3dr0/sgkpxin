{ pkgs ? import <nixpkgs> { } }:

let
  toAttr = package: {
    name = package;
    value = pkgs.callPackage ./pkgs/${package} { };
  };

  mkPackages = packages:
    pkgs.lib.pipe packages [ ( builtins.map toAttr ) builtins.listToAttrs ];
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
