#
# Makefile
#
.EXPORT_ALL_VARIABLES:

.PHONY: yaml help clean clean-configmaps clean-deployments clean-services clean-ingress apply-configmaps apply-deployments apply-services apply-ingress enable-ingress

#set default ENV based on your username and hostname
TOUCH_FILES=enable-ingress
TEMP_FOLDERS=

K_ROOT := ops/kubernetes
YAML_FILES_SRC = $(shell find $(K_ROOT) -type f -name '*.ytemplate')
YAML_FILES = $(YAML_FILES_SRC:%.ytemplate=%.yaml)

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

apply-all: enable-ingress apply-configmaps apply-deployments apply-services apply-ingress ## Apply all resources to kubernetes

apply-configmaps: $(K_CONFIGMAPS)/*.yaml ## apply the configmaps to kubernetes
	@echo "Applying configmap in $^"
	$(APPLYYML)

apply-deployments: $(K_DEPLOYMENTS)/*.yaml ## apply the deployments to kubernetes
	@echo "Applying deployments in $^"
	$(APPLYYML)

apply-services: $(K_SERVICES)/*.yaml ## apply the services to kubernetes
	@echo "Applying services in $^"
	$(APPLYYML)

apply-ingress: $(K_INGRESS)/*.yaml ## apply the ingress to kubernetes
	@echo "Applying ingress in $^"
	$(APPLYYML)

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
	-rm $(TOUCH_FILES)
	-rm -Rf $(TEMP_FOLDERS)
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
	kube-linter lint $(K_ROOT)

yaml: $(YAML_FILES) ## generate yaml files from template (subst env variables)

%.yaml: %.ytemplate
	@echo "Creating yaml files"
	@echo "Creating file $@ from $<"
	export K_NAMESPACE=$(K_NAMESPACE) && envsubst < $< > $@
