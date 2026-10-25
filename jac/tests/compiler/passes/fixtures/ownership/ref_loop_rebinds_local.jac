"""A ref-loop variable whose name the function binds elsewhere is E1306 (#9972).

The loop variable is a loan whose extent is the loop. If the function also
binds that name, before or after the loop, the program's one variable of
that name would hold the loan once the loop ends, so it would outlive it.
"""

obj Res {
    has tag: int = 0;
}

def rebinds_an_earlier_local -> int {
    xs: own list[Res] = [];
    xs.append(Res(tag=1));
    x = Res(tag=5);
    for x in &xs {
        print(x.tag);
    }
    return 0;
}

def name_bound_after_the_loop -> int {
    xs: own list[Res] = [];
    xs.append(Res(tag=1));
    for x in &xs {
        print(x.tag);
    }
    x = 3;
    return x;
}

with entry {
    print(rebinds_an_earlier_local(), name_bound_after_the_loop());
}
