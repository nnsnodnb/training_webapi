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
cleanup:
	docker compose down --rmi all -v

.PHONY: docker_maintenance_on
maintenance_on:
	docker compose exec backend pipenv run python manage.py maintenance_mode on

.PHONY: docker_maintenance_off
maintenance_off:
	docker compose exec backend pipenv run python manage.py maintenance_mode off

.PHONY: multipass_setup
multipass_setup:
	multipass launch -n training -d 10G --cloud-init multipassfiles/cloud-init.yml
	multipass restart training
	$(MAKE) multipass_install_python
	$(MAKE) multipass_mount

.PHONY: multipass_cleanup
multipass_cleanup:
	multipass stop training
	multipass delete training
	multipass purge

.PHONY: multipass_install_python
multipass_install_python:
	multipass transfer ./multipassfiles/setup_python.sh training:/home/ubuntu/setup_python.sh
	multipass exec training -- chmod +x ./setup_python.sh
	multipass exec training -- ./setup_python.sh

.PHONY: multipass_mount
multipass_mount:
	multipass mount ./ training:/home/ubuntu/training_webapi

.PHONY: multipass_start_server
multipass_start_server:
	multipass exec training -- bash /home/ubuntu/training_webapi/multipassfiles/start_server.sh
