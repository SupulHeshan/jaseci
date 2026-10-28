"""Generic methods on a generic archetype keep the archetype's type params erased.

`Holder[V]` stores `val` boxed, so a stamped `first[K]` must treat `V`
the way every other method of `Holder` does: as the box, unboxed by the
caller against the receiver's type arguments. Solving `V` from the
`alt` argument instead returned the box's address for `self.val`, and
for a `Holder[float]` called with an int literal it solved the wrong
type outright.
"""

obj Holder[V] {
    has val: V;

    def first[K](key: K, alt: V) -> V {
        return self.val;
    }

    def echo[K](key: K, alt: V) -> V {
        return alt;
    }

    def get[K](key: K) -> V {
        return self.val;
    }
}

def first_int(v: int) -> int {
    return Holder[int](val=v).first("k", 7);
}

def echo_int(v: int) -> int {
    return Holder[int](val=5).echo("k", v);
}

def get_int(v: int) -> int {
    return Holder[int](val=v).get("k");
}

def first_float_from_int_arg(v: float) -> float {
    return Holder[float](val=v).first("k", 7);
}

def echo_with_empty_spread(v: int) -> int {
    extra: dict[str, int] = {};
    return Holder[int](val=5).echo("k", v, **extra);
}

def echo_alt_from_spread(v: int) -> int {
    extra: dict[str, int] = {"alt": v};
    return Holder[int](val=5).echo("k", **extra);
}

def echo_float_alt_from_int_spread(v: int) -> float {
    extra: dict[str, int] = {"alt": v};
    return Holder[float](val=1.5).echo("k", **extra);
}

def str_echo_rejects_int_spread(v: int) -> int {
    extra: dict[str, int] = {"alt": v};
    try {
        return len(Holder[str](val="x").echo("k", **extra));
    } except TypeError {
        return -1;
    }
}

def int_echo_rejects_str_spread(n: int) -> int {
    extra: dict[str, str] = {"alt": "s" * n};
    try {
        return Holder[int](val=1).echo("k", **extra);
    } except TypeError {
        return -1;
    }
}

def first_str_len(n: int) -> int {
    return len(Holder[str](val="x" * n).first(1, "y"));
}
