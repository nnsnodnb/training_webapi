.PHONY: setup
setup:
	@$(MAKE) build
	@$(MAKE) start

.PHONY: build
build:
	@docker compose build

.PHONY: start
start:
	@docker compose up -d

.PHONY: cleanup
cleanup:
	@docker compose down --rmi all -v

.PHONY: maintenance_on
maintenance_on:
	@docker compose exec backend pipenv run python manage.py maintenance_mode on

.PHONY: maintenance_off
maintenance_off:
	@docker compose exec backend pipenv run python manage.py maintenance_mode off
