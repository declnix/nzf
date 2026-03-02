.PHONY: build run

build:
	nix build .#nixosConfigurations.nzf-test.config.system.build.vm

run:
	nix run .#nixosConfigurations.nzf-test.config.system.build.vm
