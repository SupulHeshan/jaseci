"""Graphmend runtime I/O utilities."""

from __future__ import annotations

import logging as _lg
import sys as _sys
from contextlib import suppress


def _graphmend_format(x: object) -> str:
    """
    Tensor-aware, sync-avoiding formatter.

    Avoids .cpu()/.numpy() to prevent device sync in hot paths.
    """
    try:
        import torch  # local import to avoid hard dep if torch is absent

        if isinstance(x, torch.Tensor):
            try:
                shape = tuple(x.shape)
            except Exception:
                shape = ()  # Empty tuple instead of string
            try:
                dtype = str(x.dtype)
            except Exception:
                dtype = "<unknown>"
            try:
                device = str(x.device)
            except Exception:
                device = "<unknown>"
            return f"<Tensor shape={shape} dtype={dtype} device={device}>"
    except Exception:
        pass
    try:
        return str(x)
    except Exception:
        return repr(x)


def _graphmend_flush(logs: list[tuple]) -> None:
    """
    Replay buffered I/O records *after* the compute-heavy region.

    Each record: (kind:str, args:tuple, kwargs:dict, lineno:int).
    """
    import builtins as _bi  # defer import to keep runtime light

    for rec in logs:
        try:
            kind, args, kwargs, _lineno = rec
        except Exception:
            continue

        # Format args once, lazily
        fargs = tuple(_graphmend_format(a) for a in (args or ()))

        if kind == "print":
            # honor sep/end/flush if present; always print to stdout/stderr only
            kw = dict(kwargs or {})
            # Block custom 'file' to avoid side-effects; route to stdout
            kw.pop("file", None)
            _bi.print(
                *fargs, **{k: v for k, v in kw.items() if k in ("sep", "end", "flush")}
            )

        elif kind == "logging":
            level = (kwargs or {}).get("__level__", "info").lower()
            msg = " ".join(fargs)
            log_fn = getattr(_lg, level, _lg.info)
            safe_kwargs = {
                k: v for k, v in (kwargs or {}).items() if k not in ("__level__",)
            }
            try:
                log_fn(msg, **safe_kwargs)
            except TypeError:
                log_fn(msg)

        elif kind == "syswrite":
            stream = (kwargs or {}).get("__stream__", "stdout")
            s = "".join(fargs)
            tgt = _sys.stdout if stream == "stdout" else _sys.stderr
            try:
                tgt.write(s)
            except Exception:
                _bi.print(s, end="")

        elif kind == "sysflush":
            stream = (kwargs or {}).get("__stream__", "stdout")
            tgt = _sys.stdout if stream == "stdout" else _sys.stderr
            with suppress(Exception):
                tgt.flush()

        else:
            # Unknown kind → best-effort
            _bi.print(*fargs)
