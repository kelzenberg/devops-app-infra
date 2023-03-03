# Makefile to bootstrap local kubernetes

include .env.runner

## Minikube

CERTS_PATH=./src/certificates
K8S_PATH=./src/.k8s

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
	sh $(K8S_PATH)/replace-ip.sh

.PHONY: tunnel
tunnel:
	# Enter system user password (if asked for)
	minikube tunnel

.PHONY: dashboard
dashboard:
	minikube dashboard


## Kubernetes

ENVS = production staging
TARGET_ENV = default
DB_CONFIG_PATH=./src/.k8s/database
APP_CONFIG_PATH=./src/.k8s/app
CONTROLLER_CONFIG_PATH=./src/.k8s/controller

.PHONY: $(ENVS)
$(ENVS): TARGET_ENV=$(MAKECMDGOALS)
$(ENVS): namespace database app

.PHONY: namespace
namespace:
	@echo "Setting up $@ for $(TARGET_ENV) environment..."
	kubectl apply -f ./src/.k8s/namespaces/$(TARGET_ENV).yaml

.PHONY: database
database:
	@echo "Setting up $@ for $(TARGET_ENV) environment..."
	kubectl create secret generic database-secret --from-env-file=.env.db --namespace=$(TARGET_ENV)
	kubectl apply -f $(DB_CONFIG_PATH)/db.pvc.yaml --namespace=$(TARGET_ENV)
	kubectl apply -f $(DB_CONFIG_PATH)/db.config.yaml --namespace=$(TARGET_ENV)
	kubectl apply -f $(DB_CONFIG_PATH)/db.deployment.yaml --namespace=$(TARGET_ENV)
	kubectl apply -f $(DB_CONFIG_PATH)/db.service.yaml --namespace=$(TARGET_ENV)
	kubectl apply -f $(CONTROLLER_CONFIG_PATH)/db.load-balancer.yaml --namespace=$(TARGET_ENV)

.PHONY: app
app:
	@echo "Setting up $@ for $(TARGET_ENV) environment..."
	kubectl create secret generic app-secret --from-env-file=.env.app --namespace=$(TARGET_ENV)
	kubectl apply -f $(APP_CONFIG_PATH)/app.config.yaml --namespace=$(TARGET_ENV)
	kubectl apply -f $(APP_CONFIG_PATH)/app.deployment.yaml --namespace=$(TARGET_ENV)
	kubectl apply -f $(APP_CONFIG_PATH)/app.service.yaml --namespace=$(TARGET_ENV)
	kubectl apply -f $(CONTROLLER_CONFIG_PATH)/$(TARGET_ENV).ingress.yaml --namespace=$(TARGET_ENV)

### Deploy

.PHONY: deploy-app
deploy-app:
	@echo "Running $@ for $(TARGET_ENV) environment..."
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
	@echo "Deleting every resource in $(TARGET_ENV) environment..."
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

RUNNER_TOKEN ?= $(error Please provide the generated GitHub token for the runner, either via ".env.runner" file or through "make runner-install RUNNER_TOKEN=foo")
RUNNER_PATH=./src/.github
RUNNER_VERSION=2.302.1
RUNNER_PACKAGE=actions-runner-osx-x64-$(RUNNER_VERSION).tar.gz

.PHONY: runner-install
runner-install:
	@echo "Installing GitHub Actions self-hosted runner..."
	mkdir -p $(RUNNER_PATH)/runner
	[ -f $(RUNNER_PATH)/$(RUNNER_PACKAGE) ] && echo "Actions-runner package exists. Skipping download." || curl -o $(RUNNER_PATH)/$(RUNNER_PACKAGE) -L https://github.com/actions/runner/releases/download/v$(RUNNER_VERSION)/$(RUNNER_PACKAGE)
	echo "cc061fc4ae62afcbfab1e18f1b2a7fc283295ca3459345f31a719d36480a8361  $(RUNNER_PATH)/$(RUNNER_PACKAGE)" | shasum -a 256 -c
	tar xzf $(RUNNER_PATH)/$(RUNNER_PACKAGE) -C $(RUNNER_PATH)/runner

	@echo "Configuring self-hosted runner with supplied token..."
	# Enter the name of the runner group to add this runner to: [press Enter for Default] Enter
	# Enter the name of runner: [press Enter for Steffens-MacBook] DevOps-Steffens-MacBook
	# Enter any additional labels (ex. label-1,label-2): [press Enter to skip] Enter
	$(RUNNER_PATH)/runner/config.sh --url https://github.com/kelzenberg/devops-app --token $(RUNNER_TOKEN)

.PHONY: runner-start
runner-start:
	@echo "Starting GitHub Actions self-hosted runner..."
	$(RUNNER_PATH)/runner/run.sh