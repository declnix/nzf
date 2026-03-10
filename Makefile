.PHONY: build run

build:
	rm *.qcow2 && nix build .#nixosConfigurations.nzf-test.config.system.build.vm

run:
	nix run .#nixosConfigurations.nzf-test.config.system.build.vm
