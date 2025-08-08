.PHONY: vm build clean help list

EXAMPLES := minimal
EXAMPLE ?= minimal

help: ## Show this help message
	@echo "Usage:"
	@echo "  make vm EXAMPLE=<name>     - Build and run VM with specified example"
	@echo "  make build EXAMPLE=<name>  - Build VM without running"
	@echo ""
	@echo "Examples:"
	@echo "  make vm EXAMPLE=minimal"
	@echo "  make vm EXAMPLE=development"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$' $(MAKEFILE_LIST) | grep -v "vm\|build" | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $1, $2}'

list: ## List available examples with descriptions
	@echo "Available nvf examples:"
	@echo "  minimal       - Basic nvf setup, just zsh basics"

vm: build ## Build and run VM (usage: make vm EXAMPLE=minimal)
	@echo "==> Running $(EXAMPLE) example..."
	result/bin/run-*-vm -display none -serial mon:stdio || true

build: ## Build VM (usage: make build EXAMPLE=minimal)
	@if [ ! -f examples/$(EXAMPLE).nix ]; then \
		echo "Error: Example '$(EXAMPLE)' not found!"; \
		echo "Available examples: $(EXAMPLES)"; \
		exit 1; \
	fi
	@echo "Building $(EXAMPLE) example..."
	nixos-rebuild build-vm --flake ".#$(EXAMPLE)" --show-trace

gui: build ## Run VM with GUI (usage: make gui EXAMPLE=minimal)
	@echo "Running $(EXAMPLE) example with GUI..."
	result/bin/run-*-vm

clean: ## Clean all build artifacts
	rm -f result*

fmt: ## Format nix files
	nixfmt .

check: ## Check flake
	nix flake check