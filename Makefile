.DEFAULT_GOAL := bootstrap

.PHONY: all
all: packages bootstrap

.PHONY: bootstrap
bootstrap:
	@./bootstrap.sh

.PHONY: dotfiles
dotfiles: bootstrap

.PHONY: packages
packages:
	@./packages.sh

