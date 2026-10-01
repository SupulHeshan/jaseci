"""cl test runner behaviours: npm import handling and annex resolution.

Client tests run under bun in a sealed temp dir with no `node_modules`, so
every non-relative import spec has to be rewritten to something bun can
resolve.  These cover that rewriting for modules that are not `@jac/runtime`.

They also cover which file the runner compiles (#9606). An annex is a fragment,
not a compilation unit. Directory discovery collects annex paths, and the client
branch used to hand them straight to the compiler, so the module under test was
never in the unit: the harness referenced a name nothing defined and failed at
call time with a `ReferenceError`, or, where the base module held the placement
pin the annex no longer matched, with a builtin left unlowered. The server branch
never had this because it resolves the annex to its base file first.

No base module is an answer, not a failure: a self-contained annex is a real
pattern here (`examples/jaclang_org/core/site/jacyac/fullstack.test.jac` has no
`fullstack.jac`), so it compiles as its own unit. A resolution *error* is not an
answer and propagates, since falling back to the annex would silently restore
the defect.
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
