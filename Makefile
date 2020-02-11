.DEFAULT_GOAL := bootstrap

.PHONY: all
all: bootstrap packages

.PHONY: bootstrap
bootstrap:
	@./bootstrap.sh

.PHONY: dotfiles
dotfiles: bootstrap

.PHONY: packages
packages:
	@./packages.sh

