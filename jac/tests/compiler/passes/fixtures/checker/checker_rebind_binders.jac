"""Rebinds the checker accepts, and the type each one leaves (#9972).

A `for` target writes the function's variable: a compatible element type is
accepted and narrows the name inside the loop body, the variable is still
live after the loop, and the usual exemptions hold (`_`, a `None` sentinel).
A loop in a nested function, or one reusing a module `glob` name, binds its
own function's local, as Python does.
"""

obj Base {
    has n: int = 0;
}

obj Derived(Base) {
    has extra: int = 1;
}

glob shared_name: str = "module";

def subclass_elements -> int {
    b: Base = Base();
    for b in [Derived(), Derived()] {
        print(b.extra);
    }
    return b.n;
}

def optional_narrows_in_the_body -> int {
    s: str | None = None;
    total = 0;
    for s in ["ab", "cde"] {
        total += len(s.upper());
    }
    return total;
}

def unpacking_narrows_in_the_body -> int {
    k: str | None = None;
    total = 0;
    for (k, v) in [("a", 1)] {
        total += len(k.upper()) + v;
    }
    return total;
}

def none_sentinel_evolves -> int {
    last = None;
    for last in [1, 2] {
        print(last + 1);
    }
    return 0;
}

def underscore_is_reusable {
    for _ in [1, 2] {
        print(1);
    }
    for _ in ["a"] {
        print(2);
    }
}

def the_variable_outlives_the_loop -> str {
    for word in ["a", "b"] {
        print(word);
    }
    return word.upper();
}

def nested_function_loop_is_its_own_local -> int {
    a = 5;
    def inner -> str {
        out = "";
        for a in ["x", "y"] {
            out += a;
        }
        return out;
    }
    print(inner());
    return a + 1;
}

def glob_name_as_a_loop_variable -> int {
    total = 0;
    for shared_name in [1, 2] {
        total += shared_name;
    }
    return total;
}

obj Holder {
    def collect(items: list[int]) -> list[str];
}

impl Holder.collect(items: list[int]) -> list[str] {
    found: list[str] = [];
    for item in items {
        source: str | None = None;
        if item > 1 {
            source = str(item);
        }
        if source is not None {
            found.append(source);
        }
    }
    for source in found {
        print(source.upper());
    }
    return found;
}

with entry {
    print(subclass_elements(), optional_narrows_in_the_body());
    print(unpacking_narrows_in_the_body(), none_sentinel_evolves());
    underscore_is_reusable();
    print(the_variable_outlives_the_loop());
    print(nested_function_loop_is_its_own_local(), glob_name_as_a_loop_variable());
    print(Holder().collect([1, 2]));
}
