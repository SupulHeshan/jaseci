from .mongo import mongo_db
from .redis import redis_db


def spawn_database(
    required_databases: dict, app_name: str, env_list: list, namespace: str = "default"
) -> None:
    mongodb_enabled = required_databases["mongodb_enabled"]
    redis_enabled = required_databases["redis_enabled"]
    if mongodb_enabled:
        # mongodb_name = f"{app_name}-mongodb"
        mongo_db(app_name, env_list)

    if redis_enabled:
        # redis_name = f"{app_name}-redis"
        redis_db(app_name, env_list)
