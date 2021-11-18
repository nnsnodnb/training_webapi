.PHONY: setup
setup:
	@(MAKE) build
	@(MAKE) start

.PHONY: build
build:
	@docker compose build

.PHONY: start
start:
	@docker compose up -d

.PHONY: cleanup
cleanup:
	@docker compose down --rmi all -v
