all:
.PHONY: all

arch.json: arch.nix
	nix eval --show-trace --write-to ./arch.json -f ./arch.nix

attr.json: attr.nix
	nix eval --show-trace --write-to ./attr.json -f ./attr.nix

bump: clean attr.json
	$(MAKE) -BC ../pkgs/ all
	./bump.sh
.PHONY: bump

clean:
	rm -fv ./arch.json ./attr.json
.PHONY: clean

ATTR ?= 
PKGS ?= import <nixpkgs> {}
test:
	nix-build ../../. --show-trace --arg pkgs '$(PKGS)' -A '$(ATTR)'
.PHONY: test

test-aarch64:
	$(MAKE) test ATTR='$(ATTR)' PKGS='( import <nixpkgs> { } ).pkgsCross.aarch64-darwin'
.PHONY: test-aarch64

test-x86_64:
	$(MAKE) test ATTR='$(ATTR)' PKGS='( import <nixpkgs> { } ).pkgsx86_64Darwin'
.PHONY: test-x86_64
