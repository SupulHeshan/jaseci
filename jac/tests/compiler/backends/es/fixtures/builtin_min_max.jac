"""Regression fixture for jaseci-labs/jaseci#8589.

`min`/`max` lowered straight to `Math.min`/`Math.max` with no regard for
Python's calling convention: a single argument is the *iterable* to scan,
while two or more are the values to compare directly.  `Math.min([1, 2, 3])`
is neither of those -- it silently evaluates to `NaN`.
"""

def min_of_list(items: list[int]) -> int {
    return min(items);
}

def max_of_list(items: list[int]) -> int {
    return max(items);
}

def min_of_args(a: int, b: int, c: int) -> int {
    return min(a, b, c);
}

def max_of_args(a: int, b: int, c: int) -> int {
    return max(a, b, c);
}

def str_len(s: str) -> int {
    return len(s);
}

def min_by_key(items: list[str]) -> str {
    return min(items, key=str_len);
}

def max_by_key(items: list[str]) -> str {
    return max(items, key=str_len);
}

def min_of_empty -> int {
    return min([]);
}
