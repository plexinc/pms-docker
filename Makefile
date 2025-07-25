.DEFAULT_GOAL:=help
SHELL:=/bin/bash

##@ Linting and Static Checks

.PHONY: lint lint-charts lint-yaml

lint: lint-charts lint-yaml  ## Run Helm and yaml linters

lint-charts:  ## Lint Helm chart using chart-testing
	@ct lint --config .github/linters/ct.yaml

lint-docs:  ## Lint Helm chart README
	@helm-docs --documentation-strict-mode charts/plex-media-server

lint-yaml:  ## Lint yaml files using yamllint
	@yamllint --config-file .yamllint .

lint-kubeconform:  ## Lint kubernetes manifests using kubeconform
	@helm template pms charts/plex-media-server \
		--namespace plex-media-server \
		--values charts/plex-media-server/ci/ci-values.yaml | kubeconform \
		-kubernetes-version=1.33.0 \
		-schema-location default \
		-strict \
		-output tap

##@ Update Helm chart README docs

.PHONY: docs

docs:  ## Run helm-docs to create or update chart READMEs
	@helm-docs charts/plex-media-server

##@ Helpers

.PHONY: help

help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
