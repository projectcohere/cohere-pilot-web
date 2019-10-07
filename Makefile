include ./Makefile.base.mk

# -- cosmetics --
help-column-width = 9

# -- context --
tools-bin         = ./bin
tools-rails       = $(tools-bin)/rails
tools-bundle      = $(tools-bin)/bundle
tools-yarn        = yarn
tools-pg-up       = $(shell pg_isready 1>/dev/null 2>&1; echo $$?)
tools-pg-start    = brew services start postgresql
tools-redis-up    = $(shell redis-cli ping 1>/dev/null 2>&1; echo $$?)
tools-redis-start = brew services start redis

# -- init --
## initializes the dev environment
init: i/pre i/base i/deps i/services i/db
.PHONY: init

## installs the ruby/js deps
i/deps:
	$(tools-bundle)
	$(tools-yarn)
.PHONY: i/pre

# -- init/helpers
i/pre:
ifeq ("$(shell command -v brew)", "")
	$(info ✘ brew is not installed, please see:)
	$(info - https://brew.sh)
	$(error 1)
endif
.PHONY: i/pre

i/base:
	HOMEBREW_NO_AUTO_UPDATE=1 brew bundle -v
.PHONY: i/base

i/services:
ifneq ($(tools-pg-up), 0)
	$(tools-pg-start)
endif
ifneq ($(tools-redis-up), 0)
	$(tools-redis-start)
endif
.PHONY: i/services

i/db:
	$(tools-rails) db:drop
	$(tools-rails) db:create
	$(tools-rails) db:seed
.PHONY: i/db

# -- start --
## alias for s/dev
start: s/dev
.PHONY: start

## alias for start
s: start
.PHONY: s

## starts the rails dev server
s/dev:
	$(tools-rails) server
.PHONY: s/dev

# -- db --
## alias for d/console
db: d/console
.PHONY: db

## drops, recreates, and seeds the dev db
d/reset:
.PHONY: d/reset

## connects a rails console to the dev db
d/console:
	$(tools-rails) console
.PHONY: d/console
