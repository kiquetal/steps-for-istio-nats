# Installing NATS on Kubernetes using Helm

This guide provides instructions for installing NATS in cluster mode with JetStream enabled using Helm.

## Prerequisites

- Kubernetes cluster
- Helm 3.x installed
- kubectl configured to communicate with your cluster

## Add the NATS Helm Repository

```bash
helm repo add nats https://nats-io.github.io/k8s/helm/charts/
helm repo update
```

## Create a Namespace for NATS (Optional)

```bash
kubectl create namespace nats-system
```

## Install NATS using Helm with Custom Values

The provided `values.yaml` file in this directory configures NATS with:

- Cluster mode enabled with 3 replicas
- JetStream enabled with both memory and file storage
- Authentication enabled
- Persistence for data
- Monitoring endpoints for Prometheus

To install NATS using these values:

```bash
helm install nats nats/nats \
  --namespace nats-system \
  --create-namespace \
  --values values.yaml
```

## Verify the Installation

Check if the NATS pods are running:

```bash
kubectl get pods -n nats-system
```

## Accessing NATS

### From within the cluster

Applications can access NATS using the service:

```
nats://nats:4222  # For NATS core protocol
nats://nats:4222/js  # For JetStream
```

### Using the NATS Box for testing

The NATS Box is included in the deployment and can be used for testing:

```bash
kubectl exec -it -n nats-system deployment/nats-box -- /bin/sh -l

# Once inside the NATS Box:
nats server check jetstream  # Check JetStream status
nats account info            # View account information
```

## Updating NATS configuration

To update the NATS configuration after installation:

```bash
helm upgrade nats nats/nats \
  --namespace nats-system \
  --values values.yaml
```

## Uninstalling NATS

```bash
helm uninstall nats -n nats-system
```

## Customizing the Configuration

The `values.yaml` file provided can be modified to suit your specific requirements. 
See the comments in the file for detailed information about each configuration option.
