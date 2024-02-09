ALL := appcode/rc appcode/release aqua clion datagrip dataspell fleet goland intellij-idea/edu intellij-idea/community intellij-idea/ultimate gateway space toolbox mps phpstorm pycharm/edu pycharm/community pycharm/professional rider rubymine webstorm
all: $(addprefix ../../../pkgs/jetbrains-,$(addsuffix /vars.json,$(ALL)))
.PHONY: all

../../../pkgs/%/conf.json:
	CONF='$@' ./conf.sh

../../../pkgs/%/vars.json: ../../../pkgs/%/conf.json
	CONF='$<' VARS='$@' ./vars.sh
