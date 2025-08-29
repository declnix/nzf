.PHONY: vm clean

# Run sandbox VM (headless by default)
vm: clean
	@nix run .#nixosConfigurations.vm.config.system.build.vm --show-trace -- -display none -serial mon:stdio


clean:
	@rm -f *.qcow2