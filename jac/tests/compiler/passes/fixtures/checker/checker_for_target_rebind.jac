"""A for-loop target that rebinds a local is checked against its type (#9972).

The loop writes the function's variable, so a target that rebinds a local or
a parameter to an incompatible type is E1001, the same as an assignment. A
compatible element type is accepted.
"""

obj Label {
    has text: str = "";
}

obj Base {
    has n: int = 0;
}

obj Derived(Base) {
    has extra: int = 1;
}

def tuple_target -> str {
    title = Label(text="a");
    for (kind, title) in [("top", "Top"), ("side", "Side")] {  # <-- Error
        print(kind);
    }
    return title.text;
}

def single_target -> str {
    title = Label(text="a");
    for title in ["Top", "Side"] {  # <-- Error
        print(title);
    }
    return title.text;
}

def rebinds_a_parameter(title: Label) -> str {
    for title in ["Top"] {  # <-- Error
        print(title);
    }
    return title.text;
}

def compatible_rebind -> int {
    b: Base = Base();
    for b in [Derived(), Derived()] {
        print(b.extra);
    }
    return b.n;
}

with entry {
    print(tuple_target(), single_target(), rebinds_a_parameter(Label()));
    print(compatible_rebind());
}
