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

## Install NATS using Helm with Command Line Overrides

Alternatively, you can install NATS with cluster mode and JetStream enabled using `--set` flags directly, without using a values file:

```bash
helm install nats nats/nats \
  --namespace nats-system \
  --create-namespace \
  --set config.cluster.enabled=true \
  --set config.cluster.replicas=3 \
  --set config.cluster.routeURLs.useFQDN=true \
  --set config.jetstream.enabled=true \
  --set config.jetstream.fileStore.enabled=true \
  --set config.jetstream.fileStore.pvc.enabled=true \
  --set config.jetstream.fileStore.pvc.size=10Gi \
  --set config.jetstream.fileStore.pvc.storageClassName=standard \
  --set config.jetstream.memoryStore.enabled=true \
  --set config.jetstream.memoryStore.size=1Gi \
  --set natsBox.enabled=true \
  --set reloader.enabled=true
```

This command provides the same configuration as the values.yaml file but can be used directly from the command line.

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

Or using command line overrides:

```bash
helm upgrade nats nats/nats \
  --namespace nats-system \
  --set config.cluster.replicas=5 \
  --set config.jetstream.fileStore.pvc.size=20Gi
```

## Uninstalling NATS

```bash
helm uninstall nats -n nats-system
```

## Customizing the Configuration

The `values.yaml` file provided can be modified to suit your specific requirements.
See the comments in the file for detailed information about each configuration option.
