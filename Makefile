# Adapted from https://github.com/vdice/porter-bundles/blob/master/Makefile
SHELL     := bash
BASE_DIR  := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
PORTER_HOME ?= $(BASE_DIR)/bin

REGISTRY ?= ghcr.io/clhain

define all-bundles
	@for dir in $$(ls -1 .); do \
		if [[ -e "./$$dir/porter.yaml" ]]; then \
			BUNDLE=$$dir $(MAKE) $(MAKE_OPTS) $(1) || exit $$? ; \
		fi ; \
	done
endef

.PHONY: build-bundle
build-bundle:
ifndef BUNDLE
	$(call all-bundles,build-bundle)
else
	@echo Building $(BUNDLE)...
	@cd $(BUNDLE) && porter build
endif

.PHONY: publish-bundles
publish-bundles:
ifndef BUNDLE
	$(call all-bundles,publish-bundle)
else
	@echo Publishing $(BUNDLE)...
	@cd $(BUNDLE) && porter publish --registry $(REGISTRY)
endif

get-mixins: get-porter-mixins get-other-mixins

get-porter-mixins:
	@$(foreach MIXIN, $(PORTER_MIXINS), \
		porter mixin install $(MIXIN) --version $(MIXIN_TAG) --url $(PORTER_MIXINS_URL)/$(MIXIN); \
	)

get-other-mixins:
	@porter mixin install helm3 --feed-url https://mchorfa.github.io/porter-helm3/atom.xml