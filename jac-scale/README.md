# JAC Scale Deployment Guide

## Overview

`jac scale` is a Kubernetes deployment plugin for JAC applications. It automates the deployment process by building Docker images, pushing them to DockerHub, and creating Kubernetes resources for your application and required databases.

## Parameters

### Required Parameters

| Parameter | Description |
|-----------|-------------|
| `APP_NAME` | Name of your JAC application |
| `DOCKER_USERNAME` | DockerHub username for pushing the image |
| `DOCKER_PASSWORD` | DockerHub password or access token |

### Optional Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `K8_NAMESPACE` | Kubernetes namespace to deploy the application | - |
| `K8_NODE_PORT` | NodePort to expose the service | - |
| `K8_MONGODB` | Whether MongoDB is needed (`True`/`False`) | `False` |
| `K8_POSTGRESQL` | Whether PostgreSQL is needed (`True`/`False`) | `False` |
| `K8_REDIS` | Whether Redis is needed (`True`/`False`) | `False` |

## How to run jac scale
Navigate to the folder containing your JAC application and run:

```bash
jac scale
```

## Architecture

### k8 pods structure
![k8 pod structure](diagrams\kubernetes-architecture.png)

## Steps followd by jac sale

### 1. Create JAC Application Docker Image

- Build the application image from the source directory
- Tag the image with DockerHub repository

### 2. Push Docker Image to DockerHub

- Authenticate using `DOCKER_USERNAME` and `DOCKER_PASSWORD`
- Push the image to DockerHub
- Subsequent pushes are faster since only the final image layer is pushed


### 3. Deploy application in k8

The plugin automatically:

- Creates Kubernetes Deployments for the JAC application
- Spawns necessary databases (MongoDB, PostgreSQL, Redis) as StatefulSets if requested
- Configures networking and service exposure

## Important Notes

### Implementation

- The entire `jac scale` plugin is implemented using **Python and Kubernetes client libraries**
- **No custom Kubernetes controllers** are used → easier to deploy and maintain

### Database Provisioning

- Databases are created as **StatefulSets** with persistent storage
- Databases are **only created on the first run**
- Subsequent `jac scale` calls only update application deployments
- This ensures persistent storage and avoids recreating databases unnecessarily

### Performance

- **First-time deployment** may take longer due to database provisioning and image downloading
- **Subsequent deployments** are faster since:
  - Only the application's final Docker layer is pushed and pulled
  - Only deployments are updated (databases remain unchanged)

## Usage Example

```bash
# Set required environment variables
export APP_NAME="my-jac-app"
export DOCKER_USERNAME="myusername"
export DOCKER_PASSWORD="mypassword"

# Set optional parameters
export K8_NAMESPACE="production"
export K8_NODE_PORT="30080"
export K8_MONGODB="True"
export K8_REDIS="True"

# Run jac scale
jac scale
```

## Troubleshooting

- Ensure you have proper Kubernetes cluster access configured
- Verify DockerHub credentials are correct
- Check that the specified namespace exists or will be created
- For database connection issues, verify StatefulSets are running: `kubectl get statefulsets -n <namespace>`

