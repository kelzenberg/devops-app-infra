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