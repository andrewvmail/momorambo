.PHONY: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

clean-docker-machine: ## Delete default and re-create machine name default using rancheros base
		@docker-machine rm default
		@docker-machine create -d virtualbox --virtualbox-memory "4084" \
				--virtualbox-boot2docker-url https://releases.rancher.com/os/latest/rancheros.iso default
		@docker-machine env default
		@eval $(docker-machine env default)

