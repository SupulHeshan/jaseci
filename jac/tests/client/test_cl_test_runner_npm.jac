"""cl test runner behaviours: npm import handling and annex resolution.

Client tests run under bun in a sealed temp dir with no `node_modules`, so
every non-relative import spec has to be rewritten to something bun can
resolve.  These cover that rewriting for modules that are not `@jac/runtime`.

They also cover which file the runner compiles (#9606): an annex resolves to its
base module, an annex with no base is its own unit, and a resolution error
propagates instead of silently falling back to the annex.
"""

import from pathlib { Path }
import from unittest.mock { patch }
import jaclang.compiler.driver.bccache as bccache;
import from jaclang.testing.cl_test_runner {
    module_entry_for,
    module_is_client,
    run_cl_test_file
}

glob FIXTURES = Path(__file__).parent / "fixtures",
     NPM_FIXTURE = str(FIXTURES / "cl_npm" / "test_npm_only.jac"),
     ANNEX_DIR = FIXTURES / "cl_annex",
     BASE = str(ANNEX_DIR / "widget.jac"),
     ANNEX = str(ANNEX_DIR / "widget.test.jac"),
     ORPHAN = str(ANNEX_DIR / "no_such_module.test.jac");

test "a client test importing only an npm module runs under bun" {
    assert module_is_client(NPM_FIXTURE) , (
        f"{NPM_FIXTURE} is not in the client codespace"
    );

    results = run_cl_test_file(NPM_FIXTURE);
    assert results , "cl test runner discovered no client tests";
    for res in results {
        assert res.ok , f"cl test {res.name} failed: {res.error}";
    }
}

test "a client test annex resolves to the module it belongs to" {
    for (given, want, why) in [
        (ANNEX, BASE, "an annex resolves to its base module"),
        (BASE, BASE, "a module file passes through untouched"),
        (ORPHAN, ORPHAN, "an annex with no base module is its own unit")
    ] {
        got = module_entry_for(given);
        assert got == want , f"{why}: {given} -> {got}";
    }

    fell_back = False;
    with patch.object(bccache, "discover_base_file", side_effect=OSError("boom")) {
        try {
            module_entry_for(ANNEX);
            fell_back = True;
        } except OSError {}
    }
    assert not fell_back , "a swallowed resolution failure restores the defect";

    assert module_is_client(ANNEX) , f"{ANNEX} did not inherit widget's client pin";

    results = run_cl_test_file(ANNEX);
    assert results , "no client tests discovered through the annex";
    for res in results {
        assert res.ok , f"cl test {res.name} failed through the annex: {res.error}";
    }
}
