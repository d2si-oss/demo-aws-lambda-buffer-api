help: ## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

clean_pyc: ## Remove your *.pyc files
	find . | grep .pyc$ | xargs rm

install_deps: ## Install your python dependencies
	pip install -r requirements.txt -t vendor

check: ## Check your local dependencies
	./script/check

watch: ## Run the watch script
	./script/watcher

build: ## Build the lambda-local image
	docker build -t lambda-local .
