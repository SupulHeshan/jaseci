"""Client-context consumer reaching elements `social` re-imports from `social_ops`."""

import from ..social_app { Relay, relay }

def:pub ReexportPanel -> JsxElement {
    has label: str = "";

    async can with entry {
        label = await relay("panel");
        await (root spawn Relay(name="panel"));
    }

    <div>{label}</div>
}
