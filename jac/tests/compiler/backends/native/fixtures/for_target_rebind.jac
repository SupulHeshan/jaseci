"""A `for` target that rebinds an existing local keeps Python's values (#9972).

After the loop the name holds the last element, and a zero-iteration loop
leaves the earlier value in place. The cases rebind with a type the checker
accepts, including one whose native representation differs from the
earlier value's (an int element over a float local).
"""

def float_slot_int_elems -> float {
    x: float = 0.5;
    for x in [1, 2] {
        print(x);
    }
    return x * 1.5;
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
