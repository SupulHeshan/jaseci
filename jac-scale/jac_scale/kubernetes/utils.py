import os

from dotenv import dotenv_values

from kubernetes import config
from kubernetes.config.config_exception import ConfigException


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


def is_k8s_configured() -> bool:
    """
    Detects whether Kubernetes configuration is available on this machine.
    Returns True if either a local kubeconfig or in-cluster config is valid.
    """
    try:
        # Try loading local kubeconfig (~/.kube/config)
        config.load_kube_config()
        return True
    except ConfigException:
        try:
            # Try loading in-cluster configuration
            config.load_incluster_config()
            return True
        except ConfigException:
            return False
