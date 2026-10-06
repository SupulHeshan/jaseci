"""Calls whose matched signature the checker records on the call node."""
import from typing { NamedTuple }

def plain(a: int, b: int) -> int {
    return a + b;
}

class Point(NamedTuple) {
    has x: int,
        y: int;
}

obj Box {
    has width: int,
        height: int;
}

with entry {
    plain(b=2, a=1);
    sorted([3, 1, 2], reverse=True);
    enumerate(["a"], start=1);
    Point(y=2, x=1);
    Box(height=2, width=1);
}
