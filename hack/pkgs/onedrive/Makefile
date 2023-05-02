ALL := onedrive
all: $(addprefix ../../../pkgs/,$(addsuffix /vars.json,$(ALL)))
.PHONY: all

../../../pkgs/%/conf.json:
	cat <<< "$$(jq -S . '$@')" > '$@'

../../../pkgs/%/vars.json: ../../../pkgs/%/conf.json
	CONF='$<' VARS='$@' ./vars.sh
