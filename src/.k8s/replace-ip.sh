#!/bin/bash
# $1 value you want to replace
# $2 file you want to edit

echo "Updating Minikube IP in Ingress files..."
MINIKUBE_IP=$(minikube ip)
echo "Minikube IP is $MINIKUBE_IP"
INGRESS_PATH="$(pwd)/src/.k8s/controller"
HOST="dev.$MINIKUBE_IP.nip.io" yq -i '.spec.rules[0].host = env(HOST)' $INGRESS_PATH/staging.ingress.yaml
echo "Written \"dev.$MINIKUBE_IP.nip.io\" for Staging environement"
HOST="app.$MINIKUBE_IP.nip.io" yq -i '.spec.rules[0].host = env(HOST)' $INGRESS_PATH/production.ingress.yaml
echo "Written \"app.$MINIKUBE_IP.nip.io\" for Production environement"
