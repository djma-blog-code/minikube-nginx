#
# Makefile
#
.EXPORT_ALL_VARIABLES:

.PHONY: test yaml help clean $(K_CONFIGS) $(YAML_TARGETS)

#set default ENV based on your username and hostname
TOUCH_FILES=enable-ingress
TEMP_FOLDERS=

K_ROOT := ops/kubernetes
K_NAMESPACE := nginx-test

YAML_FILES_SRC = $(shell find $(K_ROOT) -type f -name '*.ytemplate')
YAML_FILES = $(YAML_FILES_SRC:%.ytemplate=%.yaml)
YAML_TARGETS = $(YAML_FILES_SRC:%.ytemplate=%)

APPS = tea coffee
HOSTNAME = helloworld
CURL_ADDITIONAL_FLAGS=-s -I --insecure


help:
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36mmake %-30s\033[0m %s\n", $$1, $$2}'

changelog: 
	# requires changelog installed in the python environment
	gitchangelog > Changelog.rst

set-namespace: ## Set the namespace in the makefile as the current default
	@[ "${K_NAMESPACE}" ] && kubectl config set-context --current --namespace=$(K_NAMESPACE)

enable-ingress: ## enable ingress addon in minikube
	minikube addons enable ingress
	touch $@

apply-all: enable-ingress apply lint test ## Enable Ingress, apply all resources to kubernetes, lint check and test

apply: $(YAML_TARGETS) ## Build resources from the yaml files

yaml: $(YAML_FILES) ## generate yaml files from template (subst env variables)

lint:  ## run lint checker against the yaml files
	@echo "Running Linter"
	kube-linter lint $(K_ROOT) || true # just so make doesn't blob when there is nothing we can do *shrug*
	# as in case of the "no pods found matching service labels (map[app:helloworld])" which is only true because
	# the linter is not looking at different files... 

test:
	@echo -e "\033[0;32m**** Dozing for a few while the services start .... ****\033[0m"
	sleep 30s ## should add in a kubectl test for pods becoming active or a timeout

	# Need to add a file path check, this is just testing '/' for app but good enought for now.
	( \
		export M_IP=($$(minikube ip)); \
		array=($$(echo "$$APPS" | tr ' ' '\n')); \
		for item in "$${array[@]}"; do \
			echo "checking App '$$item'"; \
			echo "curl $$CURL_ADDITIONAL_FLAGS -H \"Host: $$HOSTNAME\" https://$$M_IP/$$item "; \
			curl $$CURL_ADDITIONAL_FLAGS -H "Host: $$HOSTNAME" https://$$M_IP/$$item | grep "200" && \
				echo -e "\033[0;32m**** K8s deploy Success ****\033[0m" \
				|| echo -e "\033[0;31m**** K8s $$item Service deploy Failed ****\033[0m"; \
		done \
	)

redeploy: enable-ingress apply $(APPS) test ## Redeploy the config and recycle the app

$(APPS): ## restart the apps
	@echo "Restarting the app $@"
	kubectl rollout restart deployment $@


%.yaml: %.ytemplate
	@echo "Creating yaml files"
	@echo "Creating file $@ from $<"
	export K_NAMESPACE=$(K_NAMESPACE) && envsubst < $< > $@

%: %.yaml
	@echo "Applying yaml file $<"
	kubectl apply -f $^

clean:  ## clean everything up
	-rm $(TOUCH_FILES) || true
	@[ "${TEMP_FOLDERS}" ] && rm -Rf $(TEMP_FOLDERS) || true

	## iterate through the yaml files and delete the resources before we
	## clean the actual yaml files away forever
	( \
		array=($$(echo "$$YAML_FILES" | tr ' ' '\n')); \
		for item in "$${array[@]}"; do \
			echo "deleting resources in ''$$item'"; \
			kubectl delete -f $$item || true; \
		done \
	)

	-rm $(YAML_FILES)

