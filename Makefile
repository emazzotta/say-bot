# Mazzotta bot build file.
#
# All commands necessary to go from development to release candidate should be here.

CURRENT_DIR = $(shell pwd)
export PATH := $CURRENT_DIR:$(PATH)
export PYTHONPATH := $CURRENT_DIR/api:$(PYTHONPATH)

# -----------------------------------------------------------------------------
# BUILD
# -----------------------------------------------------------------------------
.PHONY: all
all: build

.PHONY: build
build:
	@docker build --no-cache --file Dockerfile -t emazzotta/mazzotta-bot .

.PHONY: push
push:
	@docker push emazzotta/mazzotta-bot

.PHONY: run
run:
	@docker run --rm --env-file=.env emazzotta/mazzotta-bot

.PHONY: release
release:
	@kubectl rollout restart -n telegram-bot deployment.apps/telegram-bot-deployment

# -----------------------------------------------------------------------------
# DEVELOPMENT
# -----------------------------------------------------------------------------
.PHONY: bootstrap
bootstrap: build copy_env

.PHONY: copy_env
copy_env:
	@cp .env.example .env

.PHONY: restart
restart: stop start

.PHONY: start
start:
	@docker-compose up -d 

.PHONY: stop
stop:
	@docker-compose kill 

.PHONY: force_build
force_build:
	@docker-compose build --force-rm --no-cache --pull

.PHONY: clean
clean:
	@rm -rf .cache
	@rm -rf target
	@rm -f .coverage
	@find . -iname __pycache__ | xargs rm -rf
	@find . -iname "*.pyc" | xargs rm -f
