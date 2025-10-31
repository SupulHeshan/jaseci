import os
from typing import Callable

from dotenv import dotenv_values

from kubernetes import client, config
from kubernetes.client.rest import ApiException
from kubernetes.config.config_exception import ConfigException

import urllib3


def load_env_variables(code_folder: str) -> list:
    """Load env variables in .env to aws beanstalk environment."""
    env_file = os.path.join(code_folder, ".env")
    env_vars = dotenv_values(env_file)
    env_list = []
    if os.path.exists(env_file):
        for key, value in env_vars.items():
            env_list.append(
                {
                    "name": key,
                    "value": value,
                }
            )
    return env_list


def check_k8_status() -> None:
    """
    Checks if Kubernetes config is configured and the k8 API server is reachable.
    """
    try:
        # Try local kubeconfig first
        config.load_kube_config()
    except ConfigException:
        try:
            # Try in-cluster config
            config.load_incluster_config()
        except ConfigException:
            raise Exception("Kubernetes is not configured on this machine.")

    # Try pinging the Kubernetes API server
    try:
        v1 = client.CoreV1Api()
        v1.get_api_resources()  # Simple call to check connectivity
    except (ApiException, urllib3.exceptions.HTTPError, OSError):
        raise Exception(
            "Unable to connect to kubernetes APi.Check whether kubernetes cluster is up"
        )


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


def cleanup_k8_resources() -> None:
    """Delete all K8s resources (deployment, service, etc.) created for the app."""
    app_name = os.getenv("APP_NAME", "jaseci")
    namespace = os.getenv("K8_NAMESPACE", "default")
    config.load_kube_config()
    apps_v1 = client.AppsV1Api()
    core_v1 = client.CoreV1Api()

    # Define names
    deployment_name = app_name
    service_name = f"{app_name}-service"

    delete_if_exists(
        apps_v1.delete_namespaced_deployment, deployment_name, namespace, "Deployment"
    )
    delete_if_exists(
        core_v1.delete_namespaced_service, service_name, namespace, "Service"
    )
    mongodb_name = f"{app_name}-mongodb"
    mongodb_service_name = f"{mongodb_name}-service"
    redis_name = f"{app_name}-redis"
    redis_service_name = f"{redis_name}-service"

    delete_if_exists(
        apps_v1.delete_namespaced_stateful_set, mongodb_name, namespace, "StatefulSet"
    )
    delete_if_exists(
        core_v1.delete_namespaced_service, mongodb_service_name, namespace, "Service"
    )
    delete_if_exists(
        apps_v1.delete_namespaced_deployment, redis_name, namespace, "Deployment"
    )
    delete_if_exists(
        core_v1.delete_namespaced_service, redis_service_name, namespace, "Service"
    )

    print(f"All Kubernetes resources for '{app_name}' cleaned up successfully.")


def ensure_namespace_exists(namespace: str) -> None:
    """
    Ensure that a given namespace exists in the Kubernetes cluster.
    If it doesn't exist and is not 'default', it will be created.
    """
    if namespace == "default":
        return  # No need to create the default namespace

    try:
        config.load_kube_config()
        core_v1 = client.CoreV1Api()
        core_v1.read_namespace(name=namespace)
        print(f"Namespace '{namespace}' already exists.")
    except ApiException as e:
        if e.status == 404:
            print(f"Namespace '{namespace}' not found. Creating it...")
            core_v1.create_namespace(
                body={
                    "apiVersion": "v1",
                    "kind": "Namespace",
                    "metadata": {"name": namespace},
                }
            )
            print(f"Namespace '{namespace}' created successfully.")
        else:
            raise
