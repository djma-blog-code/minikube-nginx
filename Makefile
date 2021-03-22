#
# Makefile
#
.EXPORT_ALL_VARIABLES:

.PHONY: yaml help clean $(K_CONFIGS) $(YAML_TARGETS) clean-configmaps clean-deployments clean-services clean-ingress apply-configmaps apply-deployments apply-services apply-ingress enable-ingress

#set default ENV based on your username and hostname
TOUCH_FILES=enable-ingress
TEMP_FOLDERS=

K_ROOT := ops/kubernetes
YAML_FILES_SRC = $(shell find $(K_ROOT) -type f -name '*.ytemplate')
YAML_FILES = $(YAML_FILES_SRC:%.ytemplate=%.yaml)
YAML_TARGETS = $(YAML_FILES_SRC:%.ytemplate=%)

# We do these separately so we can order them.
K_CONFIGS := $(wildcard $(K_ROOT)/configmaps/*.yaml $(K_ROOT)/deployments/*.yaml $(K_ROOT)/services/*.yaml $(K_ROOT)/ingress/*.yaml)
K_DEPLOYMENTS := $(wildcard $(K_ROOT)/deployments/*.yaml)
K_SERVICES := $(wildcard $(K_ROOT)/services/*.yaml)
K_INGRESS := $(wildcard $(K_ROOT)/ingress/*.yaml)
K_NAMESPACE := nginx-test

APPS = helloworld

define APPLYYML
	echo "Applying :: $@"
	kubectl apply -f $^

endef

define DELETE_RESOURCE
	echo "Applying :: $@"
	kubectl delete -f $^ || true

endef

help:
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36mmake %-30s\033[0m %s\n", $$1, $$2}'

apply-all: enable-ingress apply ## Apply all resources to kubernetes

apply: $(YAML_TARGETS)

apply-configmaps: $(K_CONFIGS)  ## apply the configmaps to kubernetes

enable-ingress: ## enable ingress addon in minikube
	minikube addons enable ingress
	touch $@

# clean-ingress: $(K_INGRESS)/*.yaml ## clean ingress resources
# 	@echo "Cleaning out Ingress in $^"
# 	$(DELETE_RESOURCE)	

# clean-services: $(K_SERVICES)/*.yaml ## clean services resources
# 	@echo "Cleaning out services in $^"
# 	$(DELETE_RESOURCE)	

# clean-deployments: $(K_DEPLOYMENTS)/*.yaml ## clean deployment resources
# 	@echo "Cleaning out deployments in $^"
# 	$(DELETE_RESOURCE)	

# clean-configmaps: $(K_CONFIGMAPS)/*.yaml ## clean configmaps resources
# 	@echo "Cleaning out configmaps in $^"
# 	$(DELETE_RESOURCE)	

clean:  ## clean everything up
	-rm $(TOUCH_FILES) || true
	@[ "${var}" ] && rm -Rf $(TEMP_FOLDERS) || true

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

$(APPS): ## restart the apps
	@echo "Restarting the app $@"
	kubectl rollout restart deployment $@

redeploy: apply-all $(APPS) ## Redeploy the config and recycle the app


lint-requirements: ## install kubernetes linter
	@echo "Installing kubelinter"
    # probably not required....

lint: lint-requirements ## run lint checker against the yaml files
	@echo "Running Linter"
	kube-linter lint $(K_ROOT) || true # just so make doesn't blob when there is nothing we can do *shrug*
	# as in case of the "no pods found matching service labels (map[app:helloworld])" which is only true because
	# the linter is not looking at different files... 

yaml: $(YAML_FILES) ## generate yaml files from template (subst env variables)

%.yaml: %.ytemplate
	@echo "Creating yaml files"
	@echo "Creating file $@ from $<"
	export K_NAMESPACE=$(K_NAMESPACE) && envsubst < $< > $@

%: %.yaml
	@echo "Applying yaml file $<"
	kubectl apply -f $^
