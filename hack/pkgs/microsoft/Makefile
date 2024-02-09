# ALL := 365 autoupdate onedrive skype visual-studio visual-studio-code
ALL := company-portal defender edge/canary edge/dev edge/beta edge/stable excel office-licensing-helper onenote outlook powerpoint remote-desktop teams/1 teams/2 word skype-for-business
all: $(addprefix ../../../pkgs/microsoft-,$(addsuffix /vars.json,$(ALL)))
.PHONY: all

../../../pkgs/%/conf.json:
	CONF='$@' ./conf.sh

../../../pkgs/%/vars.json: ../../../pkgs/%/conf.json
	CONF='$<' VARS='$@' ./vars.sh
