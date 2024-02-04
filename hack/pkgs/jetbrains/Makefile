ALL := jetbrains-appcode/rc jetbrains-appcode/release aqua clion datagrip dataspell fleet goland jetbrains-intellij-idea/edu jetbrains-intellij-idea/community jetbrains-intellij-idea/ultimate jetbrains-gateway jetbrains-space jetbrains-toolbox mps phpstorm jetbrains-pycharm/edu jetbrains-pycharm/community jetbrains-pycharm/professional rider rubymine webstorm
all: $(addprefix ../../../pkgs/,$(addsuffix /vars.json,$(ALL)))
.PHONY: all

../../../pkgs/%/conf.json:
	CONF='$@' ./conf.sh

../../../pkgs/%/vars.json: ../../../pkgs/%/conf.json
	CONF='$<' VARS='$@' ./vars.sh
