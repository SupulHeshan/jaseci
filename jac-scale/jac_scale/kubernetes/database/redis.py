from typing import Tuple


def redis_db(app_name: str, env_vars: list) -> Tuple[dict, dict]:
    redis_name = f"{app_name}-redis"
    redis_port = 6379
    redis_service_name = f"{redis_name}-service"

    redis_statefulset = {
        "apiVersion": "apps/v1",
        "kind": "StatefulSet",
        "metadata": {"name": redis_name},
        "spec": {
            "serviceName": redis_service_name,
            "replicas": 1,
            "selector": {"matchLabels": {"app": redis_name}},
            "template": {
                "metadata": {"labels": {"app": redis_name}},
                "spec": {
                    "containers": [
                        {
                            "name": "redis",
                            "image": "redis:7.2",
                            "ports": [{"containerPort": redis_port}],
                            "args": ["--appendonly", "yes"],
                            "volumeMounts": [
                                {"name": "redis-data", "mountPath": "/data"}
                            ],
                        }
                    ],
                },
            },
            "volumeClaimTemplates": [
                {
                    "metadata": {"name": "redis-data"},
                    "spec": {
                        "accessModes": ["ReadWriteOnce"],
                        "resources": {"requests": {"storage": "512Mi"}},
                    },
                }
            ],
        },
    }

    redis_service = {
        "apiVersion": "v1",
        "kind": "Service",
        "metadata": {"name": redis_service_name},
        "spec": {
            "clusterIP": "None",
            "selector": {"app": redis_name},
            "ports": [
                {"protocol": "TCP", "port": redis_port, "targetPort": redis_port}
            ],
        },
    }

    env_vars.append(
        {
            "name": "REDIS_URL",
            "value": f"redis://{redis_service_name}:{redis_port}/0",
        }
    )

    return redis_statefulset, redis_service
