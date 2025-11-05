"""LLM abstraction module.

This module provides a LLM class that abstracts LiteLLM and offers
enhanced functionality and interface for language model operations.
"""
import from __future__ { annotations }

# flake8: noqa: E402

import os;
import from typing { Generator }
import from byllm.mtir { MTIR }

# This will prevent LiteLLM from fetching pricing information from
# the bellow URL every time we import the litellm and use a cached
# local json file. Maybe we we should conditionally enable this.
# https://raw.githubusercontent.com/BerriAI/litellm/main/model_prices_and_context_window.json

import from byllm.llm_connector {LLMConnector}
import from byllm.types {CompletionResult}

with entry {

    os.environ["LITELLM_LOCAL_MODEL_COST_MAP"] = "True";

    let SYSTEM_PERSONA = """\
This is a task you must complete by returning only the output.
Do not include explanations, code, or extra text—only the result.
""" ; # noqa E501

    let INSTRUCTION_TOOL = """
Use the tools provided to reach the goal. Call one tool at a time with \
proper args—no explanations, no narration. Think step by step, invoking tools \
as needed. When done, always call finish_tool(output) to return the final \
output. Only use tools.
""";  # noqa E501
}


obj Model {
    """A wrapper class that abstracts LiteLLM functionality.

    This class provides a simplified and enhanced interface for interacting
    with various language models through LiteLLM.
    """

    def __init__(model_name: str, **kwargs: object) -> None {
        print("Initializing JacLLM Model...");
        self.llm_connector = LLMConnector.for_model(model_name, **kwargs);
    }

    """Construct the call parameters and return self (factory pattern)."""
    def __call__(**kwargs: object) -> Model {
        self.llm_connector.call_params = kwargs;
        return self;
    }

    """Get the call parameters for the LLM."""
    @property
    def call_params() -> dict[str, object] {
        return self.llm_connector.call_params;
    }

    """Invoke the LLM with the given caller and arguments."""
    def invoke(mtir: MTIR) -> object {
        if mtir.stream {
            return self._completion_streaming(mtir);
        }
        while True {
            resp = self._completion_no_streaming(mtir);
            if resp.tool_calls {
                for tool_call in resp.tool_calls {
                    if tool_call.is_finish_call() {
                        return tool_call.get_output();
                    } else {
                        mtir.add_message(tool_call());
                    }
                }
            } else {
                break;
            }
        }
        return resp.output;
    }

    """Perform a completion request with the LLM."""
    def _completion_no_streaming(mtir: MTIR) -> CompletionResult {
        return self.llm_connector.dispatch_no_streaming(mtir);
    }

    """Perform a streaming completion request with the LLM."""
    def _completion_streaming(mtir: MTIR) -> Generator[str, None, None] {
        return self.llm_connector.dispatch_streaming(mtir);
    }
}

