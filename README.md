# Cohere Pilot (Rails)

## Table of Contents

- [Setup](#setup-)
- [Development](#development-)

## Setup [↑](#table-of-contents)

Caveat: These instructions are for MacOS.

If you don't use a tool to manage multiple ruby versions, please install one. We recommend [rbenv](https://github.com/rbenv/rbenv).

Once rbenv is installed, please install the project ruby:

```sh
$ rbenv install
```

Then run the setup command (it may prompt you to install other tools).

```sh
$ make init
```

Then start the Rails server:

```sh
$ make s
$ make s/js (optional: Webpack Dev Server)
$ make s/sk (optional: Sidekiq)
```

## Development [↑](#table-of-contents)

Most common commands can be run using `make`. To see a list of available commands, you
can always run:

```sh
$ make # or `make help`
```
