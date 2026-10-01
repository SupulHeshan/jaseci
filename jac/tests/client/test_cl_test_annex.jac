"""A client test carried in a `.test.jac` annex resolves to its module (#9606).

An annex is a fragment, not a compilation unit. Directory discovery collects
annex paths, and the client branch used to hand them straight to the compiler,
so the module under test was never in the unit: the harness referenced a name
nothing defined and failed at call time with a `ReferenceError`, or, where the
base module held the placement pin the annex no longer matched, with a builtin
left unlowered. The server branch never had this because it resolves the annex
to its base file first. Both entry points now resolve, so either path into a
module's client tests behaves the same.

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

glob FIXTURE_DIR = Path(__file__).parent / "fixtures" / "cl_annex",
     BASE = str(FIXTURE_DIR / "widget.jac"),
     ANNEX = str(FIXTURE_DIR / "widget.test.jac");


test "an annex resolves to its base module, and a module file is left alone" {
    assert module_entry_for(ANNEX) == BASE , (
        f"annex did not resolve to its base module: {module_entry_for(ANNEX)}"
    );
    assert module_entry_for(BASE) == BASE , "a module file must pass through";
}


test "a missing base file leaves the annex path untouched" {
    orphan = str(FIXTURE_DIR / "no_such_module.test.jac");
    assert module_entry_for(orphan) == orphan , (
        "an annex with no base module is its own unit and must pass through: a "
        "self-contained annex is a real pattern in this tree (see "
        "examples/jaclang_org/core/site/jacyac/fullstack.test.jac, which has no "
        "fullstack.jac and imports everything it needs)"
    );
}


test "a resolution failure propagates instead of compiling the annex alone" {
    fell_back = False;
    with patch.object(bccache, "discover_base_file", side_effect=OSError("boom")) {
        try {
            module_entry_for(ANNEX);
            fell_back = True;
        } except OSError {}
    }
    assert not fell_back , "swallowing the failure restores the defect silently";
}


test "an annex inherits its module's client placement" {
    assert module_is_client(ANNEX) , (
        f"{ANNEX} did not inherit the client placement pinned on widget"
    );
}


test "client tests in an annex pass whether reached by annex or by module" {
    for `entry in (ANNEX, BASE) {
        results = run_cl_test_file(`entry);
        assert results , f"cl test runner discovered no client tests via {`entry}";
        for res in results {
            assert res.ok , f"cl test {res.name} failed via {`entry}: {res.error}";
        }
    }
}
