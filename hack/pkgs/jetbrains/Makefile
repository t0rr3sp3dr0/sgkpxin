ALL := appcode aqua clion datagrip dataspell fleet goland intellij-idea-community-edition intellij-idea-edu intellij-idea-ultimate jetbrains-gateway jetbrains-space jetbrains-toolbox mps phpstorm pycharm-community pycharm-edu pycharm-professional rider rubymine webstorm
all: $(addprefix ../../../pkgs/,$(addsuffix /vars.json,$(ALL)))
.PHONY: all

../../../pkgs/%/conf.json:
	cat <<< "$$(jq -S . '$@')" > '$@'

../../../pkgs/%/vars.json: ../../../pkgs/%/conf.json
	CONF='$<' VARS='$@' ./vars.sh
