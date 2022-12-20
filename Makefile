.PHONY: docker_setup
docker_setup:
	$(MAKE) docker_build
	$(MAKE) docker_start

.PHONY: finch_setup
finch_setup:
	$(MAKE) finch_build
	$(MAKE) finch_start

.PHONY: docker_build
docker_build:
	docker compose build

.PHONY: finch_build
finch_build:
	finch compose build

.PHONY: docker_start
docker_start:
	docker compose up -d

.PHONY: finch_start
finch_start:
	finch compose up -d

.PHONY: docker_cleanup
docker_cleanup:
	docker compose down --rmi all -v

.PHONY: finch_cleanup
finch_cleanup:
	finch compose down -v
	finch rmi training_backend:latest training_db:latest training_proxy:latest

.PHONY: docker_maintenance_on
docker_maintenance_on:
	docker compose exec backend poetry run python manage.py maintenance_mode on

.PHONY: docker_maintenance_off
docker_maintenance_off:
	docker compose exec backend poetry run python manage.py maintenance_mode off

# .PHONY: finch_maintenance_on
# finch_maintenance_on:
# 	finch compose run backend poetry run python manage.py maintenance_mode on

# .PHONY: finch_maintenance_off
# finch_maintenance_off:
# 	finch compose run backend poetry run python manage.py maintenance_mode off
