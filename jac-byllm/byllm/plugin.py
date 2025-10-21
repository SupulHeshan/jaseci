"""Plugin for Jac's with_llm feature."""

from __future__ import annotations


from typing import Callable, TYPE_CHECKING

from jaclang.runtimelib.constructs import (
    EdgeArchetype,
    NodeArchetype,
    WalkerArchetype,
)
from jaclang.runtimelib.machine import hookimpl

if TYPE_CHECKING:
    from byllm.llm import Model
    from byllm.mtir import MTIR


class JacMachine:
    """Jac's with_llm feature."""

    @staticmethod
    @hookimpl
    def get_mtir(caller: Callable, args: dict, call_params: dict) -> object:
        """Call JacLLM and return the result."""
        from byllm.mtir import MTIR

        return MTIR.factory(caller, args, call_params)

    @staticmethod
    @hookimpl
    def call_llm(model: Model, mtir: MTIR) -> object:
        """Call JacLLM and return the result."""
        return model.invoke(mtir=mtir)

    @staticmethod
    @hookimpl
    def visit_by(
        model: Model,
        walker: WalkerArchetype,
        node: NodeArchetype,
        connected_nodes: list[NodeArchetype],
    ) -> (
        list[NodeArchetype | EdgeArchetype]
        | list[NodeArchetype]
        | list[EdgeArchetype]
        | NodeArchetype
        | EdgeArchetype
    ):
        """Go through the available nodes and decide which next nodes to visit based on their semantics using an llm."""
        from byllm.visit_by import _visit_by

        return _visit_by(model, walker, node, connected_nodes)
