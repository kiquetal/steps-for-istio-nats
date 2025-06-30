#!/bin/bash

# Script to enable Istio sidecar injection on the auth namespace using kubectl command
# This is an alternative to using the 'istio-injection: enabled' label in the namespace definition

# Check if namespace exists, if not create it
kubectl get namespace auth &>/dev/null
if [ $? -ne 0 ]; then
  echo "Creating auth namespace..."
  kubectl create namespace auth
fi

# Enable Istio sidecar injection on the auth namespace
echo "Enabling Istio sidecar injection on auth namespace..."
kubectl label namespace auth istio-injection=enabled --overwrite

echo "Istio sidecar injection has been enabled for namespace: auth"

# Verify the label
echo "Verifying namespace label:"
kubectl get namespace auth --show-labels
