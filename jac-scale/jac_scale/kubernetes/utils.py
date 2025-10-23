import os

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
