# ALL := microsoft-365 microsoft-autoupdate onedrive skype visual-studio visual-studio-code
ALL := company-portal microsoft-defender microsoft-edge-beta microsoft-edge-canary microsoft-edge-dev microsoft-edge-stable microsoft-excel microsoft-office-licensing-helper microsoft-onenote microsoft-outlook microsoft-powerpoint microsoft-remote-desktop microsoft-teams microsoft-word skype-for-business
all: $(addprefix ../../../pkgs/,$(addsuffix /vars.json,$(ALL)))
.PHONY: all

../../../pkgs/%/conf.json:
	cat <<< "$$(jq -S . '$@')" > '$@'

../../../pkgs/%/vars.json: ../../../pkgs/%/conf.json
	CONF='$<' VARS='$@' ./vars.sh
