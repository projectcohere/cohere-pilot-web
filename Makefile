include ./Makefile.base.mk

# -- cosmetics --
help-column-width = 10

# -- context --
tools-rb         = ./bin
tools-rails       = $(tools-rb)/rails
tools-bundle      = $(tools-rb)/bundle
tools-yarn        = yarn
tools-pg-up       = $(shell pg_isready 1>/dev/null 2>&1; echo $$?)
tools-pg-start    = brew services start postgresql
tools-redis-up    = $(shell redis-cli ping 1>/dev/null 2>&1; echo $$?)
tools-redis-start = brew services start redis

# -- init --
## initializes the dev environment
init: i
.PHONY: init

i: i/pre i/base i/deps i/services i/db
.PHONY: i

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
start: s
.PHONY: start

s: s/dev
.PHONY: start

## starts the rails dev server
s/dev:
	$(tools-rails) server
.PHONY: s/dev

# -- test --
## alias for t/unit
test: t
.PHONY: test

t: t/unit
.PHONY: t

## runs unit tests
t/unit:
	$(test-base)
.PHONY: t/unit

## runs unit tests and stops on exceptions
t/u/rescue:
	PRY_RESCUE=1 $(test-base)
.PHONY: t/dbg

## runs all tests
t/all:
	$(test-base-all)
.PHONY: t/all

## runs all tests and stops on exceptions
t/a/rescue:
	PRY_RESCUE=1 $(test-base-all)
.PHONY: t/dbg

# -- test/helpers
test-base     = $(tools-rails) test test/features/*_tests.rb test/features/**/*_tests.rb
test-base-all = $(test-base) test/**/*_tests.rb

# -- utilties --
## no-op, group utitlies
utils:
.PHONY: utils

## lists all the routes
u/routes:
	$(tools-rails) routes
.PHONY: u/routes

# -- db --
## alias for d/console
db: d
.PHONY: db

d: d/console
.PHONY: d

## runs seeds
d/seed:
	$(tools-rails) db:seed
.PHONY: d/seed

## loads dev fixtures
d/fixtures:
	$(tools-rails) db:fixtures:load FIXTURES=recipients,cases
.PHONY: d/fixtures

## drops, recreates, and loads dev fixtures
d/reset: d/reset/base d/fixtures
.PHONY: d/reset

d/reset/base:
	$(tools-rails) db:reset
.PHONY: d/reset/base

## runs any pending migrations
d/migrate:
	$(tools-rails) db:migrate
.PHONY: d/reset

## rolls back previous migration
d/m/undo:
	$(tools-rails) db:rollback
.PHONY: d/reset

## reapplies previous migration
d/m/redo: d/m/undo d/migrate
.PHONY: d/reset

## starts the rails dev console
d/console:
	$(tools-rails) console
.PHONY: d/console
