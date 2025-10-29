"""File covering plugin implementation."""

import os

from dotenv import load_dotenv

from jaclang.cli.cmdreg import cmd_registry
from jaclang.runtimelib.machine import hookimpl

from .kubernetes.docker_impl import build_and_push_docker
from .kubernetes.k8 import deploy_k8
from .kubernetes.utils import cleanup_k8_resources


class JacCmd:
    """Jac CLI."""

    @staticmethod
    @hookimpl
    def create_cmd() -> None:
        """Create Jac CLI cmds."""

        @cmd_registry.register
        def scale() -> None:
            """Jac Scale functionality."""
            load_dotenv()
            code_folder = os.getenv("CODE_FOLDER", os.getcwd())
            build_and_push_docker(code_folder)
            deploy_k8(code_folder)

        @cmd_registry.register
        def destroy() -> None:
            """Jac Destroys functionality."""
            load_dotenv()
            cleanup_k8_resources()
