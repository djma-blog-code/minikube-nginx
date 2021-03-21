#
# Makefile
#
.EXPORT_ALL_VARIABLES:

#set default ENV based on your username and hostname
TOUCH_FILES=enable-ingress
TEMP_FOLDERS=

#
# kubernetes deployment files
K_ROOT := ops/kubernetes
K_CONFIGMAPS := $(K_ROOT)/configmaps
K_DEPLOYMENTS := $(K_ROOT)/deployments
K_SERVICES := $(K_ROOT)/services
K_INGRESS := $(K_ROOT)/ingress

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

apply-all: enable-ingress apply-configmaps apply-deployments apply-services apply-ingress

apply-configmaps: $(K_CONFIGMAPS)/*.yaml ## apply the configmaps to kubernetes
	@echo "Applying configmap in $^"
	$(APPLYYML)

apply-deployments: $(K_DEPLOYMENTS)/*.yaml ## apply the configmaps to kubernetes
	@echo "Applying deployments in $^"
	$(APPLYYML)

apply-services: $(K_SERVICES)/*.yaml ## apply the configmaps to kubernetes
	@echo "Applying services in $^"
	$(APPLYYML)

apply-ingress: $(K_INGRESS)/*.yaml ## apply the configmaps to kubernetes
	@echo "Applying ingress in $^"
	$(APPLYYML)

enable-ingress: ## enable ingress addon in minikube
	minikube addons enable ingress
	touch $@

clean-ingress: $(K_INGRESS)/*.yaml ## clean ingress resources
	@echo "Cleaning out Ingress in $^"
	$(DELETE_RESOURCE)	

clean-services: $(K_SERVICES)/*.yaml ## clean ingress resources
	@echo "Cleaning out services in $^"
	$(DELETE_RESOURCE)	

clean-deployments: $(K_DEPLOYMENTS)/*.yaml ## clean ingress resources
	@echo "Cleaning out deployments in $^"
	$(DELETE_RESOURCE)	

clean-configmaps: $(K_CONFIGMAPS)/*.yaml ## clean ingress resources
	@echo "Cleaning out configmaps in $^"
	$(DELETE_RESOURCE)	

clean: clean-ingress clean-services clean-deployments clean-configmaps ## clean everything up
	-rm $(TOUCH_FILES)
	-rm -Rf $(TEMP_FOLDERS)

$(APPS): ## restart the apps
	@echo "Restarting the app $@"
	kubectl rollout restart deployment $@

redeploy: apply-all $(APPS) ## Redeply the config and recycle the app

.PHONY: help clean clean-configmaps clean-deployments clean-services clean-ingress apply-configmaps apply-deployments apply-services apply-ingress enable-ingress
