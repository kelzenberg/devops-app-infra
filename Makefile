# Makefile to bootstrap local kubernetes

init:
	minikube start
	minikube addons enable metrics-server
	minikube addons enable ingress
	kubectl cluster-info

tunnel:
	minikube tunnel

dashboard:
	minikube dashboard

status:
	kubectl get deployments --all
	kubectl get services --all
	kubectl get pods --all
	kubectl get daemonset --all
	kubectl get pvc --all
	kubectl get ingress --all
	kubectl get configmaps --all

cleanup:
	kubectl delete deployments --all
	kubectl delete services --all
	kubectl delete pods --all
	kubectl delete daemonset --all
	kubectl delete pvc --all
	kubectl delete ingress --all
	kubectl delete configmaps --all

db:
	kubectl apply -f ./src/.k8s/database/db.pvc.yaml
	kubectl get pvc
	kubectl apply -f ./src/.k8s/database/db.config.yaml
	kubectl get configmaps
	kubectl apply -f ./src/.k8s/database/db.deployment.yaml
	kubectl get deployments
	kubectl get pods
	kubectl apply -f ./src/.k8s/database/db.service.yaml
	kubectl get services

app:
	kubectl apply -f ./src/.k8s/app/app.deployment.yaml
	kubectl get deployments
	kubectl get services
	kubectl get pods

controller:
	kubectl apply -f ./src/.k8s/controller/ingress.yaml
	kubectl get ingress
	kubectl apply -f ./src/.k8s/controller/db.load-balancer.yaml
	kubectl get services

github-runner-install:
	$ mkdir ./src/.github && cd ./src/.github
	$ curl -o actions-runner-osx-x64-2.301.1.tar.gz -L https://github.com/actions/runner/releases/download/v2.301.1/actions-runner-osx-x64-2.301.1.tar.gz
	$ echo "3e0b037ea67e9626e99e6d3ff803ce0d8cc913938ddd1948b3a410ac6a75b878  actions-runner-osx-x64-2.301.1.tar.gz" | shasum -a 256 -c
	$ tar xzf ./actions-runner-osx-x64-2.301.1.tar.gz

	# Supply GitHub Token via CLI argument, e.g. `make github-runner-install RUNNER_TOKEN=foo`
	$ ./config.sh --url https://github.com/kelzenberg/devops-app --token $(RUNNER_TOKEN)

github-runner-start:
	$ ./src/.github/run.sh
	# Use this YAML in your workflow file for each job:
	# `runs-on: self-hosted`