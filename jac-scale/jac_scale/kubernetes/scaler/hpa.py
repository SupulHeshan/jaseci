from kubernetes import client, config
from kubernetes.client import (
    AutoscalingV2Api,
    V2CrossVersionObjectReference,
    V2HorizontalPodAutoscaler,
    V2HorizontalPodAutoscalerSpec,
    V2MetricSpec,
    V2ResourceMetricSource,
)
from kubernetes.client.exceptions import ApiException


def create_hpa(
    namespace: str,
    deployment_name: str,
    min_replicas: int = 1,
    max_replicas: int = 5,
    cpu_target: int = 50,
) -> None:
    """
    Create HPA for a deployment based on CPU utilization.
    """
    autoscaling_v2 = AutoscalingV2Api()

    hpa = V2HorizontalPodAutoscaler(
        api_version="autoscaling/v2",
        kind="HorizontalPodAutoscaler",
        metadata={"name": f"{deployment_name}-hpa"},
        spec=V2HorizontalPodAutoscalerSpec(
            scale_target_ref=V2CrossVersionObjectReference(
                api_version="apps/v1",
                kind="Deployment",
                name=deployment_name,
            ),
            min_replicas=min_replicas,
            max_replicas=max_replicas,
            metrics=[
                V2MetricSpec(
                    type="Resource",
                    resource=V2ResourceMetricSource(
                        name="cpu",
                        target={
                            "type": "Utilization",
                            "averageUtilization": cpu_target,
                        },
                    ),
                )
            ],
        ),
    )

    try:
        autoscaling_v2.create_namespaced_horizontal_pod_autoscaler(
            namespace=namespace, body=hpa
        )
        print(
            f"HPA created for Deployment '{deployment_name}' (CPU target: {cpu_target}%)"
        )
    except ApiException as e:
        if e.status == 409:
            print(f"HPA for '{deployment_name}' already exists, skipping creation.")
        else:
            raise


# create_hpa(namespace, app_name, min_replicas=1, max_replicas=5, cpu_target=50)


def enable_insecure_tls_for_metrics_server() -> None:
    """
    Adds --kubelet-insecure-tls to metrics-server deployment in kube-system namespace.
    This bypasses certificate verification errors on local clusters like Docker Desktop or Minikube.
    """
    try:
        # Load kubeconfig (works locally)
        config.load_kube_config()
    except Exception:
        # If running inside a cluster
        config.load_incluster_config()

    apps_v1 = client.AppsV1Api()
    namespace = "kube-system"
    deployment_name = "metrics-server"

    try:
        # Get current deployment
        deployment = apps_v1.read_namespaced_deployment(deployment_name, namespace)
        container = deployment.spec.template.spec.containers[0]

        # Check if arg already exists
        if "--kubelet-insecure-tls" not in container.args:
            container.args.append("--kubelet-insecure-tls")

            # Patch the deployment with the updated args
            patch = {
                "spec": {
                    "template": {
                        "spec": {
                            "containers": [
                                {"name": container.name, "args": container.args}
                            ]
                        }
                    }
                }
            }
            apps_v1.patch_namespaced_deployment(
                name=deployment_name, namespace=namespace, body=patch
            )
            print("Successfully added '--kubelet-insecure-tls' to metrics-server.")
        else:
            print("--kubelet-insecure-tls' is already enabled.")

    except ApiException as e:
        if e.status == 404:
            print("metrics-server not found in kube-system namespace.")
        else:
            print(f"Error patching metrics-server: {e}")


if __name__ == "__main__":
    enable_insecure_tls_for_metrics_server()
