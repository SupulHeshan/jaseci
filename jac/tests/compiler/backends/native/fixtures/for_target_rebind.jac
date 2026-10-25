"""A `for` target that rebinds an existing local writes that local (#9972).

The loop variable is the function's variable, not a loop-only one, so after
the loop the name holds the last element, and a zero-iteration loop leaves
the earlier value in place. Each case rebinds with a type the checker
accepts but whose native representation differs from the slot's.
"""

obj Base {
    has n: int = 0;
}

obj Derived(Base) {
    has extra: int = 100;
}

def float_slot_int_elems -> float {
    x: float = 0.5;
    for x in [1, 2] {
        x = x + 0.0;
    }
    return x * 1.5;
}

def base_slot_derived_elems -> int {
    b: Base = Base(n=1);
    for b in [Derived(n=2), Derived(n=3)] {
        print(b.extra);
    }
    return b.n;
}

def last_element_survives_the_loop -> int {
    x = 0;
    for x in [4, 5] {
        print(x);
    }
    return x;
}

def zero_iterations_keep_the_value -> int {
    x = 7;
    empty: list[int] = [];
    for x in empty {
        print(x);
    }
    return x;
}

def unpack_rebinds_the_local -> int {
    k = 0;
    for (k, v) in [(1, 10), (2, 20)] {
        print(v);
    }
    return k;
}

def optional_slot_narrows_in_body -> int {
    s: str | None = None;
    total = 0;
    for s in ["ab", "cde"] {
        total += len(s);
    }
    return total;
}
