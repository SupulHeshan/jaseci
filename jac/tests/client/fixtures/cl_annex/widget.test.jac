"""Annex for `widget`. Nothing is imported: `label` is in scope only because the
compiler merges this into `widget.jac`, so compiling it alone loses that
binding."""

test "label counts the items" {
    assert label([1, 2, 3]) == "3 items";
}
