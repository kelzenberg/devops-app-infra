# Makefile to bootstrap local kubernetes

include .env.runner

## Minikube

CERTS_PATH=./src/certificates

.PHONY: init
init: start
	minikube addons enable metrics-server
	sh $(CERTS_PATH)/generate-certs.sh
	kubectl -n kube-system create secret tls mkcert --key $(CERTS_PATH)/key.pem --cert $(CERTS_PATH)/cert.pem
	# -- Enter custom cert(format is "namespace/secret"): kube-system/mkcert
	minikube addons configure ingress
	minikube addons disable ingress
	minikube addons enable ingress
	# Only enable Docker Registry:
	# Do you want to enable Docker Registry? [y/n]: y
	# -- Enter docker registry server url: ghcr.io
	# -- Enter docker registry username: kelzenberg
	# -- Enter docker registry password: $TOKEN
	minikube addons configure registry-creds
	minikube addons enable registry-creds

.PHONY: start
start:
	minikube start --cpus 2 --memory 4g --driver=virtualbox
	kubectl cluster-info

.PHONY: tunnel
tunnel:
	# Enter system user password (if asked for)
	minikube tunnel

.PHONY: dashboard
dashboard:
	minikube dashboard


## Kubernetes

setup: staging production

ENVS = production staging
TARGET_ENV = default

.PHONY: $(ENVS)
$(ENVS): TARGET_ENV=$(MAKECMDGOALS)
$(ENVS): namespace database app

.PHONY: namespace
namespace:
	kubectl apply -f ./src/.k8s/namespaces/$(TARGET_ENV).yaml

.PHONY: database
database:
	echo "Setting up $@ for $(TARGET_ENV)..."
	kubectl create secret generic database-secret --from-env-file=.env.db --namespace=$(TARGET_ENV)
	kubectl apply -f ./src/.k8s/database/db.pvc.yaml --namespace=$(TARGET_ENV)
	kubectl apply -f ./src/.k8s/database/db.config.yaml --namespace=$(TARGET_ENV)
	kubectl apply -f ./src/.k8s/database/db.deployment.yaml --namespace=$(TARGET_ENV)
	kubectl apply -f ./src/.k8s/database/db.service.yaml --namespace=$(TARGET_ENV)
	kubectl apply -f ./src/.k8s/controller/db.load-balancer.yaml --namespace=$(TARGET_ENV)

.PHONY: app
app:
	echo "Setting up $@ for $(TARGET_ENV)..."
	kubectl create secret generic app-secret --from-env-file=.env.app --namespace=$(TARGET_ENV)
	kubectl apply -f ./src/.k8s/app/app.config.yaml --namespace=$(TARGET_ENV)
	kubectl apply -f ./src/.k8s/app/app.deployment.yaml --namespace=$(TARGET_ENV)
	kubectl apply -f ./src/.k8s/app/app.service.yaml --namespace=$(TARGET_ENV)
	kubectl apply -f ./src/.k8s/controller/$(TARGET_ENV).ingress.yaml --namespace=$(TARGET_ENV)

### Deploy

.PHONY: deploy-app
deploy-app:
	kubectl set image deployment/devops-app -n=$(TARGET_ENV) devops-app=ghcr.io/kelzenberg/devops-app:master
	kubectl rollout status -n=$(TARGET_ENV) --timeout=15m deployment/devops-app

.PHONY: deploy-app-staging
deploy-app-staging: TARGET_ENV=staging
deploy-app-staging: deploy-app

.PHONY: deploy-app-production
deploy-app-production: TARGET_ENV=production
deploy-app-production: deploy-app

### Clean

.PHONY: clean
clean:
	kubectl delete deployments --namespace=$(TARGET_ENV) --all
	kubectl delete services --namespace=$(TARGET_ENV) --all
	kubectl delete pods --namespace=$(TARGET_ENV) --all
	kubectl delete daemonset --namespace=$(TARGET_ENV) --all
	kubectl delete pvc --namespace=$(TARGET_ENV) --all
	kubectl delete ingress --namespace=$(TARGET_ENV) --all
	kubectl delete configmaps --namespace=$(TARGET_ENV) --all
	kubectl delete secrets --namespace=$(TARGET_ENV) --all

.PHONY: clean-staging
clean-staging: TARGET_ENV=staging
clean-staging: clean

.PHONY: clean-production
clean-production: TARGET_ENV=production
clean-production: clean

.PHONY: clean-all
clean-all: clean-staging clean-production
	kubectl delete namespaces $(ENVS)

## GitHub Self-hosted Runner

.PHONY: runner-install
runner-install:
	$ mkdir ./src/.github && cd ./src/.github
	$ curl -o actions-runner-osx-x64-2.301.1.tar.gz -L https://github.com/actions/runner/releases/download/v2.301.1/actions-runner-osx-x64-2.301.1.tar.gz
	$ echo "3e0b037ea67e9626e99e6d3ff803ce0d8cc913938ddd1948b3a410ac6a75b878  actions-runner-osx-x64-2.301.1.tar.gz" | shasum -a 256 -c
	$ tar xzf ./actions-runner-osx-x64-2.301.1.tar.gz

	# Supply GitHub Token via CLI argument, e.g. `make github-runner-install RUNNER_TOKEN=foo`
	$ ./config.sh --url https://github.com/kelzenberg/devops-app --token $(RUNNER_TOKEN)

.PHONY: runner-start
runner-start:
	$ ./src/.github/run.sh
	# Use this YAML in your workflow file for each job:
	# `runs-on: self-hosted`