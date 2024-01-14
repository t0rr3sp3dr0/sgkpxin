# ALL := microsoft-365 microsoft-autoupdate onedrive skype visual-studio visual-studio-code
ALL := company-portal microsoft-defender microsoft-edge-beta microsoft-edge-canary microsoft-edge-dev microsoft-edge-stable microsoft-excel microsoft-office-licensing-helper microsoft-onenote microsoft-outlook microsoft-powerpoint microsoft-remote-desktop microsoft-teams-1 microsoft-teams-2 microsoft-word skype-for-business
all: $(addprefix ../../../pkgs/,$(addsuffix /vars.json,$(ALL)))
.PHONY: all

../../../pkgs/%/conf.json:
	CONF='$@' ./conf.sh

../../../pkgs/%/vars.json: ../../../pkgs/%/conf.json
	CONF='$<' VARS='$@' ./vars.sh
