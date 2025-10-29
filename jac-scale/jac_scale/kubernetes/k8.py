"""File covering k8 automation."""

import os
import time
from typing import Callable

from kubernetes import client, config
from kubernetes.client.exceptions import ApiException

from .database.mongo import mongo_db
from .utils import check_k8_status, load_env_variables


def deploy_k8(code_folder: str) -> None:
    """Deploy jac application to k8."""
    app_name = os.getenv("APP_NAME", "jaseci")
    image_name = os.getenv("DOCKER_IMAGE_NAME", f"{app_name}:latest")
    namespace = os.getenv("K8_NAMESPACE", "default")
    container_port = int(os.getenv("K8_CONTAINER_PORT", "8000"))
    node_port = int(os.getenv("K8_NODE_PORT", "30001"))
    docker_username = os.getenv("DOCKER_USERNAME", "juzailmlwork")
    repository_name = f"{docker_username}/{image_name}"
    mongodb_enabled = os.getenv("K8_MONGODB", "false").lower() == "true"
    # redis_enabled = os.getenv("K8_REDIS", "false").lower() == "true"

    # -------------------
    # Kubernetes setup
    # -------------------
    config.load_kube_config()
    apps_v1 = client.AppsV1Api()
    core_v1 = client.CoreV1Api()

    check_k8_status()
    env_list = load_env_variables(code_folder)
    # -------------------
    # Define MongoDB deployment/service (if needed)
    # -------------------

    if mongodb_enabled:
        mongodb_name = f"{app_name}-mongodb"
        # TODO: need to integrate namespace
        mongodb_service_name = f"{mongodb_name}-service"
        mongodb_deployment, mongodb_service = mongo_db(app_name, env_list)

    deployment = {
        "apiVersion": "apps/v1",
        "kind": "Deployment",
        "metadata": {"name": app_name},
        "spec": {
            "replicas": 3,
            "selector": {"matchLabels": {"app": app_name}},
            "template": {
                "metadata": {"labels": {"app": app_name}},
                "spec": {
                    "containers": [
                        {
                            "name": app_name,
                            "image": repository_name,
                            "ports": [{"containerPort": container_port}],
                            "env": env_list,
                        }
                    ],
                },
            },
        },
    }

    # -------------------
    # Define Service for Jaseci-app
    # -------------------
    service = {
        "apiVersion": "v1",
        "kind": "Service",
        "metadata": {"name": f"{app_name}-service"},
        "spec": {
            "selector": {"app": app_name},
            "ports": [
                {
                    "protocol": "TCP",
                    "port": container_port,
                    "targetPort": container_port,
                    "nodePort": node_port,
                }
            ],
            "type": "NodePort",
        },
    }

    # -------------------
    # Helper to delete existing resources safely
    # -------------------
    def delete_if_exists(
        delete_func: Callable, name: str, namespace: str, kind: str
    ) -> None:
        """Deploy example."""
        try:
            delete_func(name, namespace)
            print(f"Deleted existing {kind} '{name}'")
        except ApiException as e:
            if e.status == 404:
                print(f"{kind} '{name}' not found, skipping delete.")
            else:
                raise

    # -------------------
    # Cleanup old resources
    # -------------------
    delete_if_exists(
        apps_v1.delete_namespaced_deployment, app_name, namespace, "Deployment"
    )
    delete_if_exists(
        core_v1.delete_namespaced_service, f"{app_name}-service", namespace, "Service"
    )
    time.sleep(5)

    # -------------------
    # Deploy resources
    # -------------------
    if mongodb_enabled:
        print("Deploying MongoDB...")

    # Check if StatefulSet already exists
    try:
        apps_v1.read_namespaced_stateful_set(name=mongodb_name, namespace=namespace)
        print(
            f"MongoDB StatefulSet '{mongodb_name}' already exists, skipping creation."
        )
    except ApiException as e:
        if e.status == 404:
            print(
                f"MongoDB StatefulSet '{mongodb_name}' not found. Creating new one..."
            )
            apps_v1.create_namespaced_stateful_set(
                namespace=namespace, body=mongodb_deployment
            )
            print(f"MongoDB StatefulSet '{mongodb_name}' created.")
        else:
            raise

    # Check if Service already exists
    try:
        core_v1.read_namespaced_service(name=mongodb_service_name, namespace=namespace)
        print(
            f"MongoDB Service '{mongodb_service_name}' already exists, skipping creation."
        )
    except ApiException as e:
        if e.status == 404:
            print(
                f"MongoDB Service '{mongodb_service_name}' not found. Creating new one..."
            )
            core_v1.create_namespaced_service(namespace=namespace, body=mongodb_service)
            print(f"MongoDB Service '{mongodb_service_name}' created.")
        else:
            raise

    print(f"MongoDB deployed and ready (service: '{mongodb_service_name}')")

    print("Deploying Jaseci-app app...")
    apps_v1.create_namespaced_deployment(namespace=namespace, body=deployment)
    core_v1.create_namespaced_service(namespace=namespace, body=service)

    print(f"Deployment complete! Access Jaseci-app at http://localhost:{node_port}")
    # if mongodb_enabled:
    #     print(
    #         f"MongoDB accessible at '{mongodb_service_name}:{mongodb_port}' inside cluster."
    #     )
