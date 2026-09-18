"""Regression fixture for jaseci-labs/jac#9120.

Builtin keyword arguments must resolve to their declared parameter by
name, not by the order they were written in -- two calls below only
differ in the order `key=`/`reverse=` are written, and must still
produce identical, correct results.
"""

def str_len(s: str) -> int {
    return len(s);
}

def sorted_variants(items: list[any]) -> dict[any, any] {
    return {
        "reverse_only": sorted(items, reverse=True),
        "key_then_reverse": sorted(items, key=str_len, reverse=True),
        "reverse_then_key": sorted(items, reverse=True, key=str_len)
    };
}

def round_kwarg(n: float) -> float {
    return round(n, ndigits=2);
}

def sum_kwarg(xs: list[any]) -> int {
    return sum(xs, start=10);
}

def enumerate_kwarg(xs: list[any]) -> any {
    return enumerate(xs, start=5);
}
