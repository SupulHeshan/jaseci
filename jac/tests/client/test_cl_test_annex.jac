"""A client test carried in a `.test.jac` annex resolves to its module (#9606).

An annex is a fragment, not a compilation unit. Directory discovery collects
annex paths, and the client branch used to hand them straight to the compiler,
so the module under test was never in the unit: the harness referenced a name
nothing defined and failed at call time with a `ReferenceError`, or, where the
base module held the placement pin the annex no longer matched, with a builtin
left unlowered. The server branch never had this because it resolves the annex
to its base file first. Both entry points now resolve, so either path into a
module's client tests behaves the same.
"""

import from pathlib { Path }
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
        "an annex with no base file must be returned unchanged so the compiler "
        "reports the real problem"
    );
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
