import os

from dotenv import dotenv_values


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
