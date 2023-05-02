# nixpkgs-t0rr3sp3dr0

## Install

```bash
nix-channel --add https://github.com/t0rr3sp3dr0/nixpkgs/archive/HEAD.tar.gz t0rr3sp3dr0
nix-channel --update
```

## Use

```bash
nix-env -iA t0rr3sp3dr0.intellij-idea-community-edition
nix-shell -p '( import <t0rr3sp3dr0> { } ).visual-studio-code'
```
