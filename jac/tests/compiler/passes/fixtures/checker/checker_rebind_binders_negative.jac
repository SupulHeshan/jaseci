"""Every binder that rebinds a local is checked against its type (#9972).

A `for` target, an unpacking target, a walrus and a `with` alias each write
the function's variable, so rebinding it to an incompatible type is E1001,
the same as `title = "Top"`. One error per function, on the marked line.
"""

obj Label {
    has text: str = "";
}

def for_tuple_target -> str {
    title = Label(text="a");
    for (kind, title) in [("top", "Top"), ("side", "Side")] {  # <-- E1001
        print(kind);
    }
    return "";
}

def for_single_target -> str {
    title = Label(text="a");
    for title in ["Top", "Side"] {  # <-- E1001
        print(title);
    }
    return "";
}

def for_rebinds_a_parameter(title: Label) -> str {
    for title in ["Top"] {  # <-- E1001
        print(title);
    }
    return "";
}

def two_loops_reuse_a_name {
    for x in [1, 2] {
        print(x);
    }
    for x in ["a", "b"] {  # <-- E1001
        print(x);
    }
}

def unpacking_assignment {
    title = Label(text="a");
    (kind, title) = ("top", "Top");  # <-- E1001
    print(kind);
}

def walrus_rebind {
    title = Label(text="a");
    if (title := "Top") {  # <-- E1001
        print(title);
    }
}

def with_alias {
    title = Label(text="a");
    with open("/dev/null") as title {  # <-- E1001
        print(1);
    }
}

obj Holder {
    def build -> None;
}

impl Holder.build -> None {
    title = Label(text="a");
    for title in ["Top"] {  # <-- E1001
        print(title);
    }
}

with entry {
    print(for_tuple_target(), for_single_target(), for_rebinds_a_parameter(Label()));
    two_loops_reuse_a_name();
    unpacking_assignment();
    walrus_rebind();
    with_alias();
    Holder().build();
}
