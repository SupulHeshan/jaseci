"""Tests for ExecutionContext isolation from stale ambient runtime state.

App identity (`base_path_dir`, `full_target_path`) used to live on
`JacRuntime` as process-global statics that decided each
`ExecutionContext`'s L3 SQLite file. Two clients in the same process
(notably `JacTestClient` instances) need to be isolated from each
other — a stale `full_target_path` from a prior client must not poison
the L3 filename of a freshly-created context.

These tests pin the contract: an ExecutionContext's persistence path is
decided by its own per-context base_path/target_path, captured at
construction time. The pre-context seeds (`Jac.set_base_path` /
`Jac.set_full_target_path`) only feed contexts that don't get explicit
values; subsequent seed mutations cannot poison a live ctx.
"""

import os;
import from pathlib { Path }
import from tempfile { TemporaryDirectory }
import from jaclang.runtime.context { ExecutionContext }
import from jaclang.server.session { Session }
import from jaclang.runtime.runtime { JacRuntime }

node RequestValue {
    has value: int = 1;
}

test "persistent field writes mark the active request memory dirty" {
    import from jaclang.runtime.memory { Memory }
    original = JacRuntime.exec_ctx;
    outer = ExecutionContext(_parent=JacRuntime.get_context());
    outer.mem = Memory();
    request = ExecutionContext(_parent=outer);
    request.mem = Memory();
    JacRuntime.exec_ctx = outer;
    token = JacRuntime.push_request_context(request);
    try {
        item = RequestValue();
        JacRuntime.save(item);
        request.mem.commit();
        item.value = 2;
        assert item.value == 2;
        assert item.__jac__.id in request.mem._dirty;
        assert not outer.mem._dirty;
        assert item.__jac__.owning_memory() is request.mem;
    } finally {
        JacRuntime.reset_request_context(token);
        JacRuntime.exec_ctx = original;
    }
}


test "field writes mark the session holding the anchor, not the pushed context" {
    # The mirror of the test above: here the anchor was loaded by the *caller*
    # and is written while a request context is pushed. Picking the session
    # from ambient state gets exactly one of these two directions right, so
    # both have to be pinned at once.
    import from jaclang.runtime.memory { Memory }
    original = JacRuntime.exec_ctx;
    outer = ExecutionContext(_parent=JacRuntime.get_context());
    outer.mem = Memory();
    request = ExecutionContext(_parent=outer);
    request.mem = Memory();
    JacRuntime.exec_ctx = outer;
    try {
        item = RequestValue();
        JacRuntime.save(item);
        outer.mem.commit();
        assert item.__jac__.owning_memory() is outer.mem;

        token = JacRuntime.push_request_context(request);
        try {
            item.value = 3;
        } finally {
            JacRuntime.reset_request_context(token);
        }
        assert item.value == 3;
        assert item.__jac__.id in outer.mem._dirty;
        assert not request.mem._dirty , (
            "a session that never loaded the anchor must not be told to write it"
        );
    } finally {
        JacRuntime.exec_ctx = original;
    }
}


test "a field write reaches its session with no context referencing it" {
    # Nothing ambient points at the owning session: it is neither pushed nor
    # the global, and it is not an ancestor of either. Resolving the session
    # from the anchor is what makes this work; walking the context chain
    # would not find it.
    import from jaclang.runtime.memory { Memory }
    original = JacRuntime.exec_ctx;
    parent = JacRuntime.get_context();
    owner_ctx = ExecutionContext(_parent=parent);
    owner_ctx.mem = Memory();
    bystander = ExecutionContext(_parent=parent);
    bystander.mem = Memory();
    JacRuntime.exec_ctx = owner_ctx;
    try {
        item = RequestValue();
        JacRuntime.save(item);
        owner_ctx.mem.commit();

        JacRuntime.exec_ctx = bystander;
        item.value = 4;
        assert item.value == 4;
        assert item.__jac__.id in owner_ctx.mem._dirty;
        assert not bystander.mem._dirty;
    } finally {
        JacRuntime.exec_ctx = original;
    }
}


test "an anchor rebinds when a different session takes it" {
    # Two sessions holding the same id hold two distinct anchor objects, so a
    # write only ever has one correct destination. Re-putting the same object
    # moves the binding rather than leaving it on the previous session.
    import from jaclang.runtime.memory { Memory }
    original = JacRuntime.exec_ctx;
    first = Memory();
    second = Memory();
    ctx = ExecutionContext(_parent=JacRuntime.get_context());
    ctx.mem = first;
    JacRuntime.exec_ctx = ctx;
    try {
        item = RequestValue();
        JacRuntime.save(item);
        assert item.__jac__.owning_memory() is first;
        second.put(item.__jac__);
        assert item.__jac__.owning_memory() is second;
        first.commit();
        second.commit();
        item.value = 5;
        assert item.value == 5;
        assert item.__jac__.id in second._dirty;
        assert not first._dirty;
    } finally {
        JacRuntime.exec_ctx = original;
    }
}


test "ExecutionContext uses explicit per-context target_path, ignoring stale seed state" {
    # Standalone .jac files (no jac.toml in their directory) — `get_name`
    # resolves to the filename stem, which gives us two distinct
    # identities to assert on without relying on the JacConfig cache
    # state (which is process-global and out of scope here).
    with TemporaryDirectory() as proj_a, TemporaryDirectory() as proj_b {
        a_target = str(Path(proj_a) / "alpha_app.jac");
        b_target = str(Path(proj_b) / "beta_app.jac");
        orig_base = JacRuntime.get_base_path_dir();
        orig_target = JacRuntime.get_full_target_path();
        orig_ctx = JacRuntime.exec_ctx;
        try {
            # Stale seed state from a hypothetical prior client/CLI run.
            JacRuntime.set_base_path(proj_a);
            JacRuntime.set_full_target_path(a_target);

            # A new context constructed with EXPLICIT per-context base and
            # target — this is the contract a multi-client process needs.
            ctx = ExecutionContext(base_path_dir=proj_b, full_target_path=b_target);

            assert isinstance(ctx.mem, Session);
            loc = ctx.mem.data_location();
            assert loc is not None , "store not initialized";

            # The store identity must reflect beta, not the stale alpha seed.
            assert "beta_app" in loc , f"data location {loc} should reflect 'beta_app'";
            assert "alpha_app" not in loc , f"data location {loc} leaked stale seed 'alpha_app'";

            ctx.close();
        } finally {
            JacRuntime.set_base_path(orig_base);
            JacRuntime.set_full_target_path(orig_target);
            JacRuntime.exec_ctx = orig_ctx;
        }
    }
}


test "two ExecutionContexts in one process keep independent persistence paths" {
    with TemporaryDirectory() as proj_a, TemporaryDirectory() as proj_b {
        a_target = str(Path(proj_a) / "alpha_app.jac");
        b_target = str(Path(proj_b) / "beta_app.jac");
        orig_base = JacRuntime.get_base_path_dir();
        orig_target = JacRuntime.get_full_target_path();
        orig_ctx = JacRuntime.exec_ctx;
        try {
            ctx_a = ExecutionContext(base_path_dir=proj_a, full_target_path=a_target);
            ctx_b = ExecutionContext(base_path_dir=proj_b, full_target_path=b_target);

            a_path = ctx_a.mem.data_location();
            b_path = ctx_b.mem.data_location();
            assert a_path is not None;
            assert b_path is not None;

            assert a_path != b_path , "two contexts collapsed onto the same store";
            assert "alpha_app" in a_path;
            assert "beta_app" in b_path;

            ctx_a.close();
            ctx_b.close();
        } finally {
            JacRuntime.set_base_path(orig_base);
            JacRuntime.set_full_target_path(orig_target);
            JacRuntime.exec_ctx = orig_ctx;
        }
    }
}


test "ExecutionContext without explicit base/target falls back to JacRuntime seeds" {
    # Back-compat: existing call sites (CLI commands, plugins) that
    # construct `ExecutionContext()` with no args get values from the
    # pre-context seeds set via `Jac.set_base_path` /
    # `Jac.set_full_target_path`.
    with TemporaryDirectory() as tmpdir {
        orig_base = JacRuntime.get_base_path_dir();
        orig_target = JacRuntime.get_full_target_path();
        orig_ctx = JacRuntime.exec_ctx;
        try {
            JacRuntime.set_base_path(tmpdir);
            JacRuntime.set_full_target_path(str(Path(tmpdir) / "standalone.jac"));

            ctx = ExecutionContext();
            assert isinstance(ctx.mem, Session);
            loc = ctx.mem.data_location();
            assert loc is not None;
            # Standalone file (no jac.toml in tmpdir) — get_name() falls back
            # to the filename stem.
            assert "standalone" in loc , f"expected 'standalone' in {loc}";

            ctx.close();
        } finally {
            JacRuntime.set_base_path(orig_base);
            JacRuntime.set_full_target_path(orig_target);
            JacRuntime.exec_ctx = orig_ctx;
        }
    }
}
