ALL := aqua appcode/rc appcode/release clion/classic clion/nova datagrip dataspell dotmemory dottrace fleet gateway goland intellij-idea/edu intellij-idea/community intellij-idea/ultimate mps phpstorm pycharm/edu pycharm/community pycharm/professional rider rubymine rustrover space-desktop toolbox webstorm writerside
all: $(addprefix ../../../pkgs/jetbrains-,$(addsuffix /vars.json,$(ALL)))
.PHONY: all

../../../pkgs/%/conf.json:
	CONF='$@' ./conf.sh

../../../pkgs/%/vars.json: ../../../pkgs/%/conf.json
	CONF='$<' VARS='$@' ./vars.sh
