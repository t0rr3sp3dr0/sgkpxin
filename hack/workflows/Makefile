all:
.PHONY: all

arch.json: arch.nix
	nix eval --show-trace --write-to ./arch.json -f ./arch.nix

attr.json: attr.nix
	nix eval --show-trace --write-to ./attr.json -f ./attr.nix

ATTR ?= 
PKGS ?= import <nixpkgs> {}
check:
	nix-build ../../. --show-trace --arg pkgs '$(PKGS)' -A '$(ATTR)'
.PHONY: check

check-aarch64:
	$(MAKE) check ATTR='$(ATTR)' PKGS='( import <nixpkgs> { } ).pkgsCross.aarch64-darwin'
.PHONY: check-aarch64

check-x86_64:
	$(MAKE) check ATTR='$(ATTR)' PKGS='( import <nixpkgs> { } ).pkgsx86_64Darwin'
.PHONY: check-x86_64
