# ALL := mono-framework dotnet-7 dotnet-6 dotnet-maui dotnet-maui-android dotnet-maui-android dotnet-maui-ios dotnet-maui-maccatalyst dotnet-webassembly-build-tools dotnet-tvos dotnet-macos xamarin-android xamarin-ios xamarin-mac xamarin-profiler eclipse-temurin-jdk microsoft-build-of-openjdk android-sdk
ALL := visual-studio
all: $(addprefix ../../../pkgs/,$(addsuffix /vars.json,$(ALL)))
.PHONY: all

../../../pkgs/%/conf.json:
	CONF='$@' ./conf.sh

../../../pkgs/%/vars.json: ../../../pkgs/%/conf.json
	CONF='$<' VARS='$@' ./vars.sh
