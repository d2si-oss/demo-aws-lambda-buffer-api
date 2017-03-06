platform := $(shell uname)
deps := terraform entr

help: ## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

install: install-tools ## The install rule sets up the development environment on the machine it's ran on.

ifeq (${platform},Darwin)
install-tools:
	brew install ${deps}
	@echo "Install Apex - serverless architecture tool"
	curl https://raw.githubusercontent.com/apex/apex/master/install.sh | sh
else
install-tools:
	@echo "${platform} is a platform we have no presets for, you'll have to install the third party dependencies manually"
	@echo "Install Apex - serverless architecture tool"
	curl https://raw.githubusercontent.com/apex/apex/master/install.sh | sh
endif

.PHONY: help
