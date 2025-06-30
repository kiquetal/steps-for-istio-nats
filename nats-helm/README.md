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

## Securing NATS with Token Authentication

You can secure your NATS installation using token authentication. First, create a Kubernetes secret containing your authentication token:

```bash
# Create a random token
TOKEN=$(openssl rand -hex 16)
echo "Generated token: $TOKEN"

# Create a Kubernetes secret with the token
kubectl create secret generic nats-auth \
  --namespace nats-system \
  --from-literal=token=$TOKEN
```

Then, when installing NATS with Helm, include the token authentication configuration:

```bash
helm install nats nats/nats \
  --namespace nats-system \
  --create-namespace \
  --set config.cluster.enabled=true \
  --set config.cluster.replicas=3 \
  --set config.jetstream.enabled=true \
  --set "config.merge.authorization.token=9279e3c9ada3e4372f43a027b15d05b2" \
  --set "natsBox.contexts.default.merge.token=9279e3c9ada3e4372f43a027b15d05b2"
```

This configuration:
- Creates a secure token stored in a Kubernetes secret
- Configures NATS to use this token for client-to-server authentication
- Also uses the same token for cluster node authentication

When connecting clients to NATS, they will need to include this token:
```
nats://token@nats:4222
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
nats://nats:4222  # For NATS core protocol (without authentication)
nats://<token>@nats:4222  # For NATS core protocol (with token authentication)
nats://<token>@nats:4222/js  # For JetStream (with token authentication)
```

### Using the NATS Box for testing

The NATS Box is included in the deployment and can be used for testing:

```bash
kubectl exec -it -n nats-system deployment/nats-box -- /bin/sh -l

# Once inside the NATS Box:
nats server check jetstream  # Check JetStream status
nats account info            # View account information
```

## Advanced Authentication Options

Besides simple token authentication, NATS supports various authentication mechanisms:

1. **Username/Password Authentication**
   ```bash
   kubectl create secret generic nats-users \
     --namespace nats-system \
     --from-literal=users.json='{"users":[{"username":"admin","password":"s3cr3t!"},{"username":"user","password":"pwd123"}]}'
     
   helm install nats nats/nats \
     --namespace nats-system \
     --create-namespace \
     --set "config.merge.authorization.users={\"valueFrom\":{\"secretKeyRef\":{\"name\":\"nats-users\",\"key\":\"users.json\"}}}"
   ```

2. **TLS Authentication**
   ```bash
   # Create TLS certificates (example using cert-manager or manually)
   # ...
   
   helm install nats nats/nats \
     --namespace nats-system \
     --set config.tls.enabled=true \
     --set config.tls.secretName=nats-tls-certs
   ```

3. **JWT-Based Authentication**
   NATS also supports JWT and NKeys for more advanced authentication scenarios.

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

## Using a Private Registry

If you need to pull the NATS images from a private registry (e.g., GitLab Container Registry), follow these steps:

### 1. Create a Kubernetes Secret for Registry Authentication

```bash
kubectl create secret docker-registry gitlab-registry \
  --namespace nats-system \
  --docker-server=registry.gitlab.com \
  --docker-username=<your-gitlab-username> \
  --docker-password=<your-gitlab-access-token> \
  --docker-email=<your-email>
```

### 2. Configure Helm to Use the Private Registry

When installing NATS, add the following parameters to specify the registry and pull secrets:

```bash
helm install nats nats/nats \
  --namespace nats-system \
  --create-namespace \
  --set global.image.registry=registry.gitlab.com/your-group/your-project \
  --set global.image.pullSecretNames[0]=gitlab-registry \
  --set config.cluster.enabled=true \
  --set config.cluster.replicas=3 \
  --set config.jetstream.enabled=true
```

### 3. Custom Image Names

If your images have custom names or paths in the registry, you can specify them individually:

```bash
helm install nats nats/nats \
  --namespace nats-system \
  --create-namespace \
  --set global.image.registry=registry.gitlab.com/your-group \
  --set global.image.pullSecretNames[0]=gitlab-registry \
  --set container.image.repository=your-project/nats \
  --set reloader.image.repository=your-project/nats-server-config-reloader \
  --set natsBox.container.image.repository=your-project/nats-box \
  --set config.cluster.enabled=true \
  --set config.jetstream.enabled=true
```

## Uninstalling NATS

```bash
helm uninstall nats -n nats-system
```

## Customizing the Configuration

The `values.yaml` file provided can be modified to suit your specific requirements.
See the comments in the file for detailed information about each configuration option.
