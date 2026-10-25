"""Two ref loops may reuse a loop variable's name: each binds its own loan.

The first loop's loan is checked on its own even though a later loop over a
different owner reuses the name, so growing `xs` inside it is still E1303
(#9972).
"""

obj Res {
    has tag: int = 0;
}

def work -> int {
    xs: own list[Res] = [];
    xs.append(Res(tag=1));
    ys: own list[Res] = [];
    ys.append(Res(tag=2));
    t = 0;
    for x in &xs {
        t = t + x.tag;
        xs.append(Res(tag=9));
    }
    for x in &mut ys {
        x.tag = x.tag + 1;
    }
    return t;
}

with entry {
    print(work());
}
