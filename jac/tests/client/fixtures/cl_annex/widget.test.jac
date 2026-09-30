"""Tests for `widget`, carried in an annex rather than the module file.

Nothing is imported: `label` is in scope only because the compiler merges this
annex into `widget.jac`. Compiling this file on its own loses that binding.
"""

test "label counts the items" {
    assert label([1, 2, 3]) == "3 items";
}
