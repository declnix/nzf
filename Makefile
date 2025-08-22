.PHONY: sandbox

# Run sandbox VM (headless by default)
sandbox:
	nix run .#nixosConfigurations.sandbox.config.system.build.vm -- -display none -serial mon:stdio