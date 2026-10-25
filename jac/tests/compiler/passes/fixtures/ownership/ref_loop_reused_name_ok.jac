"""Ref loops that reuse one loop-variable name are each a fresh loan (#9972)."""

obj Res {
    has tag: int = 0;
}

def work -> int {
    xs: own list[Res] = [];
    xs.append(Res(tag=1));
    t = 0;
    for x in &xs {
        t = t + x.tag;
    }
    for x in &mut xs {
        x.tag = x.tag * 2;
    }
    for x in &xs {
        t = t + x.tag;
    }
    return t + len(xs);
}

with entry {
    print(work());
}
