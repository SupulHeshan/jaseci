"""Bug #NONECALL-1: implicit-None return of an unannotated call flagged as
a type mismatch against an explicit `-> None` return.

`bump` has no return type annotation, so get_type_of_ability() fell back to
the raw NoneType class (not the instance form) for its inferred return type.
`caller` declares `-> None`, whose declared return type IS converted to the
instance form. Comparing the two produced a spurious E1002 ("Cannot return
NoneType, expected NoneType") on top of the expected E1003.
"""

def bump {
    return 0;
}

def caller -> None {
    return bump();
}
