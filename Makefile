# Build configuration
# -------------------

APP_NAME = "Bagheera"
APP_VERSION = "0.1.0"
GIT_REVISION = `git rev-parse HEAD`

# Introspection targets
# ---------------------

.PHONY: help
help: header targets

.PHONY: header
header:
	@echo "\033[34mEnvironment\033[0m"
	@echo "\033[34m---------------------------------------------------------------\033[0m"
	@printf "\033[33m%-23s\033[0m" "APP_NAME"
	@printf "\033[35m%s\033[0m" $(APP_NAME)
	@echo ""
	@printf "\033[33m%-23s\033[0m" "APP_VERSION"
	@printf "\033[35m%s\033[0m" $(APP_VERSION)
	@echo "\n"

.PHONY: targets
targets:
	@echo "\033[34mTargets\033[0m"
	@echo "\033[34m---------------------------------------------------------------\033[0m"
	@perl -nle'print $& if m{^[a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-22s\033[0m %s\n", $$1, $$2}'

# Build targets
# -------------

.PHONY: build
build: ## Compile Elm source
	elm make src/Main.elm --output=public/app.js

.PHONY: clean
clean: ## Remove cached deps
	rm -rf elm-stuff
	rm -rf node_modules

# Development targets
# -------------------

.PHONY: format
format: ## Format code
	elm-format src/Main.elm --yes

.PHONY: start
start: ## Run server with HMR
	elm-live src/Main.elm --open --hot --dir=public -- --debug --output=public/app.js

.PHONY: test
test: ## Run the test suite
	elm-test
