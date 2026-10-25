"""A `for` target that rebinds a local writes that local on native (#9972).

The checker binds a `for` target in the function's scope, so a loop that
rebinds an existing name is one variable, as it is on Python. These cases
pin the native result for rebinds the checker accepts: the slot's type and
the element's differ (float vs int, Base vs Derived), the loop runs zero
times, the target unpacks, and a wider declaration narrows in the body.
"""

import ctypes;
import from tests.support { compile_native, get_func }

test "a for target rebinding a float local leaves the last element" {
    (_eng, _ir) = compile_native("for_target_rebind.jac");
    f = get_func(_eng, "float_slot_int_elems", ctypes.c_double);
    assert f() == 3.0 , f"x holds 2 after the loop, so 2 * 1.5, got {f()}";
}

test "a for target rebinding a base-class local reads the last element" {
    (_eng, _ir) = compile_native("for_target_rebind.jac");
    f = get_func(_eng, "base_slot_derived_elems", ctypes.c_int64);
    assert f() == 3 , f"b is the last Derived after the loop, got {f()}";
}

test "the loop variable survives the loop and a zero-iteration loop keeps it" {
    (_eng, _ir) = compile_native("for_target_rebind.jac");
    f = get_func(_eng, "last_element_survives_the_loop", ctypes.c_int64);
    assert f() == 5 , f"x is the last element after the loop, got {f()}";
    g = get_func(_eng, "zero_iterations_keep_the_value", ctypes.c_int64);
    assert g() == 7 , f"an empty loop leaves x as it was, got {g()}";
}

test "an unpacking for target rebinds the local" {
    (_eng, _ir) = compile_native("for_target_rebind.jac");
    f = get_func(_eng, "unpack_rebinds_the_local", ctypes.c_int64);
    assert f() == 2 , f"k is the last pair's key after the loop, got {f()}";
}

test "an optional local narrows to the element type in the loop body" {
    (_eng, _ir) = compile_native("for_target_rebind.jac");
    f = get_func(_eng, "optional_slot_narrows_in_body", ctypes.c_int64);
    assert f() == 5 , f"len('ab') + len('cde'), got {f()}";
}
