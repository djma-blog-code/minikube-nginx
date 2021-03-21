# Hello World minikube Nginx

Work in progress to deploy out configurable nginx as a reverse proxy with either LDAP SSO or client certs to redeploy my private servers to cloud

I used the article [Tutorial: Deploy Your First Kubernetes Cluster](https://www.appvia.io/blog/tutorial-deploy-kubernetes-cluster "Tutorial: Deploy Your First Kubernetes Cluster") as a guide to start from. The index.html and index2.html are shamelessly reused from this article, at least for tag stage_1.x.x

This project contains all the resources and code required to:

1. Configure nginx with `index.html` and `index2.html`
2. Deploy these as ConfigMap resources
3. Map these files as a volume and serve with nginx
4. Deploy the Service wrapper
5. Deploy the Ingress rules to access the Nginx web pages

Once deployed, the following command will test the service has deployed correctly.

`export IP=$(minikube ip)`

`curl -v -s -I -H 'Host: helloworld' "http://$IP/`

and this should give the 2nd page in the mapped volume

`curl -v -s -I -H 'Host: helloworld' "http://$IP/index2.html`

Additionally if you have access, you can issue the command `sudo echo $(IP) helloworld >> /etc/hosts`, you can browse to the pages in your browser of choice.

## Dependencies

1. Installed and working docker environment
2. Installed and working minikube environment
3. User access to all above resources, no `sudo` required or coded for. So user must be in the `docker` group.
4. GNU Make (usually installed with dev tools on a linux machine). The project was built and tested with `GNU Make 4.3`

Software versions tested with

- `minikube` - v1.17.1
- `kubectl` - v1.20.2 (server and client)
- `docker` - 20.10.2

## Folder Structure

```text

.
└── ops
    └── kubernetes
        ├── configmaps
        ├── deployments
        ├── ingress
        └── service

```

## Files of note

- `/ops/kubernetes/**/*.yaml` Definition files for the kubernetes resources. ConfigMaps, Deployments, Service and Ingress
- `Makefile` The brains of the operation, all the automation macros to build, test and deploy the solution.

## Order of Execution

1. `make apply-all` - Applies all the resources in a sensible order
2. `make redeploy` - Redeploys the resources and restarts the pods associated with `$(APPS)`
3. `make clean` - cleans up temporary files and deletes all the resources

## Makefile Recipes

The Makefile is self documenting so just run `make` and it will provide the list of available recipes

- `make apply-all` Apply all resources to kubernetes
- `make apply-configmaps` apply the configmaps to kubernetes
- `make apply-deployments` apply the deployments to kubernetes
- `make apply-ingress` apply the ingress to kubernetes
- `make apply-services` apply the services to kubernetes
- `make clean` clean everything up
- `make clean-configmaps` clean configmaps resources
- `make clean-deployments` clean deployment resources
- `make clean-ingress` clean ingress resources
- `make clean-services` clean services resources
- `make enable-ingress` enable ingress addon in minikube
- `make redeploy` Redeploy the config and recycle the app

## Cleaning up

To clean the environment after review `make clean` will remove the minikube resources and any temporary files from the local machine

## TODO
