# Hello World minikube Nginx

Work in progress to deploy out configurable nginx as a reverse proxy with either LDAP SSO or client certs to redeploy my private servers to cloud

I used the article [Tutorial: Deploy Your First Kubernetes Cluster](https://www.appvia.io/blog/tutorial-deploy-kubernetes-cluster "Tutorial: Deploy Your First Kubernetes Cluster") as a guide to start from. The index.html and index2.html are shamelessly reused from this article, at least for tag stage_1.x.x

This project contains all the resources and code required to:

1. Configure nginx with `index.html` and `index2.html`
2. Deploy these as ConfigMap resources
3. Map these files as a volume and serve with nginx
4. Deploy the Service wrapper
5. Deploy the Ingress rules to access the Nginx web pages

Once deployed, the following command will test the service has deployed correctly `make test` (although it has an annoying 30s currently).

Additionally if you have access, you can add `minikube ip` to `/etc/hosts` with hostname `helloworld` so you can browse to the pages in your browser of choice. `<browser of choice> http://helloworld/`.

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

1. `make apply-all` - Applies all the resources in a sensible order, lints and tests
2. `make redeploy` - Redeploys the resources and restarts the pods associated with `$(APPS)`
3. `make clean` - cleans up temporary files and deletes all the resources

## Makefile Recipes

The Makefile is self documenting so just run `make` and it will provide the list of available recipes

- `make enable-ingress` enable ingress addon in minikube
- `make apply-all` Enable Ingress, apply all resources to kubernetes, lint check and test
- `make apply` Build resources from the yaml files
- `make yaml` generate yaml files from template (subst env variables)
- `make lint` run lint checker against the yaml files
- `make redeploy` Redeploy the config and recycle the app
- `make clean` clean everything up

## Cleaning up

To clean the environment after review `make clean` will remove the minikube resources and any temporary files from the local machine

## References

Collection of links to useful docs

- [Tutorial: Deploy Your First Kubernetes Cluster](https://www.appvia.io/blog/tutorial-deploy-kubernetes-cluster "Tutorial: Deploy Your First Kubernetes Cluster")
- [Troubleshooting Kubernetes Deployments](https://learnk8s.io/troubleshooting-deployments "Troubleshooting Kubernetes Deployments")
- [Analyze Kubernetes files for errors with KubeLinter](https://opensource.com/article/21/1/kubelinter "Analyze Kubernetes files for errors with KubeLinter")

## TODO

- from linting changes `readOnlyRootFilesystem` and `runAsUser` cause and issue in the container startup as nginx needs read-write to the root filesystem (see:[Issue #416 docker-nginx](https://github.com/nginxinc/docker-nginx/issues/416 "Issue #416 docker-nginx") ). Will come back to this no doubt as it is a security issue and will need fixing.

  ```
  /docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
  10-listen-on-ipv6-by-default.sh: info: can not modify /etc/nginx/conf.d/default.conf (read-only file system?)
  /docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
  /docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
  /docker-entrypoint.sh: Configuration complete; ready for start up
  2021/03/22 00:01:38 [warn] 1#1: the "user" directive makes sense only if the master process runs with super-user privileges, ignored in /etc/nginx/nginx.conf:2
  nginx: [warn] the "user" directive makes sense only if the master process runs with super-user privileges, ignored in /etc/nginx/nginx.conf:2
  2021/03/22 00:01:38 [emerg] 1#1: mkdir() "/var/cache/nginx/client_temp" failed (30: Read-only file system)
  nginx: [emerg] mkdir() "/var/cache/nginx/client_temp" failed (30: Read-only file system

  ```

- Add in a better check for the services being available than a `sleep 30s`, I know a man who would be frustrated by the wait :)
