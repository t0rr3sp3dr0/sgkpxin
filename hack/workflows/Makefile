all:
.PHONY: all

arch.json: arch.nix
	nix eval --show-trace --write-to ./arch.json -f ./arch.nix

attr.json: attr.nix
	./attr.sh

clean:
	rm -fv ./arch.json ./attr.json
.PHONY: clean

bump:
	./bump.sh
.PHONY: bump

merge:
	gh pr review '$(PR_N)' -a
	gh pr merge '$(PR_N)' -m --auto
.PHONY: merge

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
