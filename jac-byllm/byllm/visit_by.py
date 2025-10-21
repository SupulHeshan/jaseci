"""This module contains functions for visiting and describing nodes in a graph-like structure."""

from __future__ import annotations

# from jaclang.runtimelib.builtin import *
from byllm.lib import Model

from jaclang import JacMachineInterface as _
from jaclang.runtimelib.constructs import (
    EdgeArchetype,
    NodeArchetype,
    WalkerArchetype,
)


def get_where_to_visit_next(
    model: Model,
    walker: WalkerArchetype,
    current_node: NodeArchetype,
    connected_nodes: list[NodeArchetype | EdgeArchetype],
    description: str = "",
) -> list[int]:
    """Call LLM to analyze semantics and determine the next nodes to visit."""

    @_.by(model=model)
    def _get_where_to_visit_next(
        walker: WalkerArchetype,
        current_node: NodeArchetype,
        connected_nodes: list[NodeArchetype | EdgeArchetype],
        description: str = "",
    ) -> list[int]:
        """Determine the next nodes to visit by analyzing semantics using an LLM.

        Walker is a transitioning agent while the nodes are agents that can be visited.
        It returns the list of indexes of the next nodes to visit in order to complete the task of the walker.
        If no suitable node is found, it returns [].
        """
        return []

    return _get_where_to_visit_next(walker, current_node, connected_nodes, description)


def _visit_by(
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
    if not isinstance(model, Model):
        raise TypeError("Invalid llm object")
    if not connected_nodes:
        raise ValueError("No connected agents found for the walker")
    next_node_indexes = get_where_to_visit_next(
        model,
        walker,
        node,
        connected_nodes,
        description=_.describe_object_list(connected_nodes),
    )
    ordered_list = []
    for index in next_node_indexes:
        if index < len(connected_nodes) and index >= 0:
            ordered_list.append(connected_nodes[index])
        else:
            raise IndexError("Index out of range for connected nodes")

    _.visit(walker, ordered_list)
    return ordered_list
