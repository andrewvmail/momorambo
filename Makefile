.PHONY: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

clean-docker-machine: ## Delete default and re-create machine name default using rancheros base
		@docker-machine rm default
		@docker-machine create -d virtualbox --virtualbox-memory "4084" \
				--virtualbox-boot2docker-url https://releases.rancher.com/os/latest/rancheros.iso default
		@docker-machine env default
		@eval $(docker-machine env default)

update_terraform_ssh_keys: ## Update Digital Ocean SSH Keys on Terraform Files (DO_TOKEN required)
	@echo "Pulling keys from DO need DO_TOKEN to be set in bashrc or zshrc file"
	@echo "Using token: ${DO_TOKEN} "
	$(eval SSH_KEYS=$(shell curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer ${DO_TOKEN}" "https://api.digitalocean.com/v2/account/keys"))
	$(eval SSH_KEYS=$(shell echo '${SSH_KEYS}' | jq -c '.ssh_keys[].id' | tr '\n' ',' | sed 's/\(.*\),/\1 /' ))
	cp terraform/main.tf ./terraform/main.tf.bak
	sed 's/.*ssh_keys.*/    ssh_keys = [ $(subst /,\/,$(SSH_KEYS)) ]/' terraform/main.tf.bak > terraform/main.tf
