include ./Makefile.base.mk

# -- cosmetics --
help-column-width = 10

# -- context --
tools-rb          = ./bin
tools-rails       = $(tools-rb)/rails
tools-spring      = $(tools-rb)/spring
tools-sidekiq     = $(tools-rb)/sidekiq
tools-wds         = $(tools-rb)/webpack-dev-server
tools-bundle      = $(tools-rb)/bundle
tools-bundle-ver  = $$(cat Gemfile.lock | tail -n 1 | tr -d ' \t')
tools-yarn        = yarn
tools-pg-up       = $(shell pg_isready 1>/dev/null 2>&1; echo $$?)
tools-pg-start    = brew services start postgresql@11
tools-redis-up    = $(shell redis-cli ping 1>/dev/null 2>&1; echo $$?)
tools-redis-start = brew services start redis

# -- init --
## initializes the dev environment
init: .env i/pre i/system i/services i/deps d/r/all i/hooks
.PHONY: init

## installs the ruby/js deps
i/deps: i/pre
ifeq ("$(shell gem list bundler | grep $(tools-bundle-ver))", "")
	gem install bundler -v $(tools-bundle-ver)
endif

	$(tools-bundle)
	$(tools-yarn)
.PHONY: i/deps

# -- init/helpers
.env:
	cp .env.sample .env

i/pre:
ifeq ("$(shell command -v ruby)", "/usr/bin/ruby")
	$(info ✘ using the system ruby:)
	$(info - please use a ruby management tool (e.g. https://github.com/rbenv/rbenv))
	$(error 1)
endif
ifeq ("$(shell command -v brew)", "")
	$(info ✘ brew is not installed, please see:)
	$(info - https://brew.sh)
	$(error 1)
endif
ifeq ("$(shell command -v yarn)", "")
	$(info ✘ yarn is not installed, please run:)
	$(info - brew install yarn)
	$(error 1)
endif
.PHONY: i/pre

i/system:
	HOMEBREW_NO_AUTO_UPDATE=1 brew bundle -v
.PHONY: i/system

i/services:
ifneq ($(tools-pg-up), 0)
	$(tools-pg-start)
endif
ifneq ($(tools-redis-up), 0)
	$(tools-redis-start)
endif
.PHONY: i/services

i/hooks: .git/hooks/pre-push
.PHONY: i/hooks

.git/hooks/pre-push:
	cd .git/hooks && ln -s ../../hooks/pre-push

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

## starts the js dev server
s/js:
	$(tools-wds)
.PHONY: s/dev

## starts the sidekiq process
s/sk:
	$(tools-sidekiq) -c 1 -q default -q mailers
.PHONY: s/dev

# -- kill --
## alias for k/rails
kill: k/rails
.PHONY: kill

## kill the rails server
k/rails:
	lsof -t -i:3000 | xargs kill -9
.PHONY: k/rails

## kill the webpack dev server
k/js:
	lsof -t -i:3035 | xargs kill -9
.PHONY: k/js

## kill all related processes
k/reap: k/rails k/js
	@pkill -9 ruby && echo "bye ruby" || true
	@pkill -9 rails && echo "bye rails" || true
	@pkill -9 spring && echo "bye spring" || true
	@pkill -9 make && echo "bye make" || true
.PHONY: k/reap

# -- test --
## alias for t/unit
test: t
.PHONY: test

t: t/unit
.PHONY: t

## runs unit tests
t/unit:
	$(call run-tests,$(tests-path))
.PHONY: t/unit

## runs unit/integration tests
t/int:
	$(call run-tests,$(tests-path-int))
.PHONY: t/int

## runs unit/integration/functional tests
t/fun:
	$(call run-tests,$(tests-path-fun))
.PHONY: t/fun

## runs system tests
t/system:
	$(call run-tests,$(tests-path-sys))
.PHONY: t/system

## runs all tests
t/all:
	$(call run-tests,$(tests-path-all))
.PHONY: t/all

## runs failed tests
t/fail:
	$(tools-rails) test $(tests-path-fail)
.PHONY: t/fail

# -- test/helpers
define run-tests
	$(tools-rails) test $$(find $(1) -name "*_tests.rb")
endef

tests-path      = test/infra test/domain test/web
tests-path-int  = $(tests-path) test/integration
tests-path-fun  = $(tests-path-int) test/functional
tests-path-sys  = test/system
tests-path-all  = test
tests-path-fail = $$(cat tmp/failures.log | paste -sd " " -)

# -- utilties --
## no-op, group utitlies
utils:
.PHONY: utils

## lists all the routes
u/routes:
	$(tools-rails) routes
.PHONY: u/routes

## stops spring
u/unspring:
	$(tools-spring) stop
.PHONY: u/unspring

# -- db --
## alias for d/console
db: d
.PHONY: db

d: d/console
.PHONY: d

## runs prod seeds
d/seed:
	$(tools-rails) db:seed
.PHONY: d/seed

## loads dev seeds
d/s/dev: d/fixtures
	$(tools-rails) db:seed:dev
.PHONY: d/s/dev

## loads fixtures
d/fixtures:
	$(tools-rails) db:fixtures:load
.PHONY: d/fixtures

## drops, recreates, and seeds the db
d/reset:
	$(tools-rails) db:reset
.PHONY: d/reset

## resets the db and loads fixtures
d/r/all: d/reset d/s/dev
.PHONY: d/r/all

## runs any pending migrations
d/migrate:
	$(tools-rails) db:migrate
.PHONY: d/migrate

## rolls back previous migration
d/m/undo:
	$(tools-rails) db:rollback
.PHONY: d/m/undo

## runs and rolls back migration
d/m/check: d/migrate d/m/undo
.PHONY: d/m/check

## starts the rails dev console
d/console:
	$(tools-rails) console
.PHONY: d/console

# -- demo --
# -- db --
## alias for t
demo: t
.PHONY: t

t: t/build
.PHONY: t

## build the static demo site
t/build:
	$(tools-rails) assets:precompile
	HOST=http://localhost:8000 $(tools-rails) demo:build
.PHONY: t/build

## serve the static demo site
t/start:
	./demo-server
.PHONY: t/start
