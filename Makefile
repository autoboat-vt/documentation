.DEFAULT_GOAL := release
.SHELLFLAGS := -c
SHELL := /usr/bin/env bash

.PHONY: add commit push deploy release

add:
	git add -A

commit:
	@read -e -p "Commit message: " message; \
	if [ -z "$$message" ]; then \
		echo "Commit message is required."; \
		exit 1; \
	fi; \
	git commit -m "$$message"

push:
	git push

deploy:
	mkdocs gh-deploy

release:
	$(MAKE) add
	$(MAKE) commit
	$(MAKE) push
	$(MAKE) deploy
