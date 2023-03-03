#!/usr/bin/env bash

echo "Generating certificates..."
MINIKUBE_IP=$(minikube ip)
echo "Minikube IP is $MINIKUBE_IP"
CERT_PATH="$(pwd)/src/certificates"
mkcert -key-file ${CERT_PATH}/key.pem -cert-file ${CERT_PATH}/cert.pem localhost 127.0.0.1 ::1 $MINIKUBE_IP *.$MINIKUBE_IP