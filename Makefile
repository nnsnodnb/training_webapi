.PHONY: docker_setup
docker_setup:
	$(MAKE) docker_build
	$(MAKE) docker_start

.PHONY: docker_build
docker_build:
	docker compose build

.PHONY: docker_start
docker_start:
	docker compose up -d

.PHONY: docker_cleanup
docker_cleanup:
	docker compose down --rmi all -v

.PHONY: docker_maintenance_on
docker_maintenance_on:
	docker compose exec backend poetry run python manage.py maintenance_mode on

.PHONY: docker_maintenance_off
docker_maintenance_off:
	docker compose exec backend poetry run python manage.py maintenance_mode off

.PHONY: multipass_setup
multipass_setup:
	multipass launch -n training -d 10G --cloud-init multipassfiles/cloud-init.yml
	multipass restart training
	$(MAKE) multipass_mount
	multipass exec training -- sudo /srv/setup.sh
	$(MAKE) multipass_start_server
	multipass info training

.PHONY: multipass_cleanup
multipass_cleanup:
	multipass stop training
	multipass delete training
	multipass purge

.PHONY: multipass_mount
multipass_mount:
	multipass mount ./ training:/home/ubuntu/training_webapi
	multipass mount ./multipassfiles/postgres_data training:/home/ubuntu/postgres_data
	multipass mount ./multipassfiles/minio_data training:/home/ubuntu/minio_data

.PHONY: multipass_start_server
multipass_start_server:
	multipass exec training -- /srv/start_server.sh

.PHONY: multipass_maintenance_on
multipass_maintenance_on:
	multipass exec training -- /srv/maintenance.sh on

.PHONY: multipass_maintenance_off
multipass_maintenance_off:
	multipass exec training -- /srv/maintenance.sh off
