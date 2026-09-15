COMPOSE = docker compose -f development/docker-compose-common.yml -f development/docker-compose-php.yml

.PHONY: up stop down logs status initialize shell
up:
	$(COMPOSE) up -d --build --wait --wait-timeout 180
stop:
	$(COMPOSE) stop
down:
	$(COMPOSE) down
logs:
	$(COMPOSE) logs -f --tail=100
status:
	$(COMPOSE) ps
initialize:
	curl --fail-with-body --max-time 180 -X POST http://127.0.0.1:8080/api/initialize
shell:
	$(COMPOSE) exec webapp bash

# Original project targets
MAKE=make -C

DOCKER_BUILD=docker build
DOCKER_BUILD_OPTS=--no-cache
DOCKER_RMI=docker rmi -f

ISUPIPE_TAG=isupipe:latest

test: test_benchmarker
.PHONY: test

test_benchmarker:
	$(MAKE) bench test
.PHONY: test_benchmarker

build_webapp:
	$(MAKE) webapp/go docker_image
.PHONY: build_webapp

