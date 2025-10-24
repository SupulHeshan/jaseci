"""JacFormatPass for Jaseci Ast.

This is a pass for formatting Jac code.
"""

from collections import deque
from typing import Deque, Optional, Tuple

import jaclang.compiler.passes.tool.doc_ir as doc
import jaclang.compiler.unitree as uni
from jaclang.compiler.passes import Transform
from jaclang.settings import settings


class JacFormatPass(Transform[uni.Module, uni.Module]):
    """JacFormat Pass format Jac code."""

    def pre_transform(self) -> None:
        """Initialize pass."""
        self.indent_size = 4
        self.MAX_LINE_LENGTH = settings.max_line_length
        self._suffix_queue: list[str] = []
        self._anchor_idx: Optional[int] = None
        self._SUFFIX_SEPARATORS = {"]", "}", ")", ",", ";"}

    def _flush_suffix_into(
        self, chunks: list[str], default_append: bool = True
    ) -> None:
        if not self._suffix_queue:
            return
        # IR already provides leading spaces ("  # 12"), so join as-is
        out = "".join(self._suffix_queue)
        self._suffix_queue.clear()

        if self._anchor_idx is not None and 0 <= self._anchor_idx < len(chunks):
            insert_pos = self._anchor_idx + 1
            chunks.insert(insert_pos, out)
            self._anchor_idx = insert_pos
        elif default_append:
            chunks.append(out)

    def _probe_fits(
        self,
        node: doc.DocType,
        indent_level: int,
        width_remaining: int,
        *,
        max_steps: int = 2000,
    ) -> bool:
        """
        Check if flat can be used early.

        returns True if `node` could be printed *flat* on the current line within
        `width_remaining` columns at `indent_level`.
        Stops early on overflow or hard/literal lines.
        """
        # Worklist holds (node, indent_level). We only ever push FLAT in a probe.
        work: Deque[Tuple[object, int]] = deque()
        work.append((node, indent_level))
        steps = 0
        remaining = width_remaining

        while work:
            if steps >= max_steps:
                # Safety cutoff: if it's *that* complex, assume it doesn't fit.
                return False
            steps += 1

            cur, lvl = work.pop()

            if isinstance(cur, doc.Text):
                remaining -= len(cur.text)
                if remaining <= 0:
                    return False

            elif isinstance(cur, doc.Line):
                if cur.hard or cur.literal:
                    # Any *real* newline (hard or literal) in FLAT means "doesn't fit"
                    return False
                if cur.tight:
                    # tight softline disappears in flat mode
                    continue
                # regular soft line becomes a single space in flat mode
                remaining -= 1
                if remaining <= 0:
                    return False

            # --- Structural nodes (walk children in LIFO) ---
            elif isinstance(cur, doc.Concat):
                # push reversed so we process left-to-right as work is a stack
                for p in reversed(cur.parts):
                    work.append((p, lvl))

            elif isinstance(cur, doc.Group):
                # Probe is always FLAT for groups.
                work.append((cur.contents, lvl))

            elif isinstance(cur, doc.Indent):
                # In flat mode, indentation has no effect until a newline; keep lvl in case
                # children contain Lines (which would have already returned False).
                work.append((cur.contents, lvl + 1))

            elif isinstance(cur, doc.Align):
                # In flat mode, alignment doesn’t change width immediately (no newline),
                # but we carry its virtual indent so nested (illegal) Line would be caught.
                align_spaces = cur.n if cur.n is not None else self.indent_size
                extra_levels = align_spaces // self.indent_size
                work.append((cur.contents, lvl + extra_levels))

            elif isinstance(cur, doc.IfBreak):
                # Flat branch while probing
                work.append((cur.flat_contents, lvl))

            elif isinstance(cur, doc.LineSuffix):
                if cur.text != ";":
                    return False  # signal: cannot be flat at *parent*
                # semicolon is okay in flat mode; charge width
                remaining -= len(cur.text)
                if remaining <= 0:
                    return False

            else:
                raise ValueError(f"Unknown DocType in probe: {type(cur)}")

        return True

    def transform(self, ir_in: uni.Module) -> uni.Module:
        """After pass."""
        ir_in.gen.jac = self.format_doc_ir()
        return ir_in

    def format_doc_ir(
        self,
        doc_node: Optional[doc.DocType] = None,
        indent_level: int = 0,
        width_remaining: Optional[int] = None,
        is_broken: bool = False,
    ) -> str:
        """Recursively print a Doc node or a list of Doc nodes, supporting LineSuffix."""
        if doc_node is None:
            doc_node = self.ir_in.gen.doc_ir

        if width_remaining is None:
            width_remaining = self.MAX_LINE_LENGTH

        if isinstance(doc_node, doc.Text):
            # If this text is a separator, we may need to flush queued suffixes *after* it.
            s = doc_node.text
            return s

        elif isinstance(doc_node, doc.Line):
            # newline -> flush queued suffix before emitting it
            if is_broken or doc_node.hard:
                suffix = "".join(self._suffix_queue)
                self._suffix_queue.clear()
                s = suffix + "\n" + " " * (indent_level * self.indent_size)
                self._anchor_idx = None
                return s
            elif doc_node.literal:
                suffix = "".join(self._suffix_queue)
                self._suffix_queue.clear()
                s = suffix + "\n"
                self._anchor_idx = None
                return s
            elif doc_node.tight:
                return ""
            else:
                return " "

        elif isinstance(doc_node, doc.Group):
            fits_flat = self._probe_fits(
                doc_node.contents,
                indent_level=indent_level,
                width_remaining=width_remaining,
            )
            return self.format_doc_ir(
                doc_node.contents,
                indent_level,
                width_remaining,
                is_broken=not fits_flat,
            )

        elif isinstance(doc_node, doc.Indent):
            new_indent_level = indent_level + 1
            return self.format_doc_ir(
                doc_node.contents,
                new_indent_level,
                width_remaining,  # width_for_indented_content  # Budget for lines within indent
                is_broken,  # is_broken state propagates
            )

        elif isinstance(doc_node, doc.Concat):
            parts = doc_node.parts
            result: list[str] = []
            current_line_budget = width_remaining

            saved_anchor = self._anchor_idx
            self._anchor_idx = None

            i = 0
            while i < len(parts):
                part = parts[i]

                # --- Lookahead: if this is a Line, slurp following LineSuffix nodes ---
                if isinstance(part, doc.Line):
                    j = i + 1
                    while j < len(parts) and isinstance(parts[j], doc.LineSuffix):
                        self._suffix_queue.append(parts[j].text)
                        j += 1
                    # We will skip those suffix nodes by advancing i to j after we process this part

                # Render current part
                part_str = self.format_doc_ir(
                    part, indent_level, current_line_budget, is_broken
                )

                # If a newline will be emitted by this part, and we still somehow have queued suffixes,
                # make sure they go into the current line at the anchor before the newline chunk
                if "\n" in part_str and self._suffix_queue:
                    self._flush_suffix_into(result, default_append=True)

                # Trim trailing space before newline
                if part_str.startswith("\n") and result and result[-1].endswith(" "):
                    result[-1] = result[-1].rstrip(" ")

                # Append the rendered piece
                result.append(part_str)

                # If the raw part is a separator token, move the anchor to here
                if isinstance(part, doc.Text) and part.text in self._SUFFIX_SEPARATORS:
                    self._anchor_idx = len(result) - 1

                # If newline occurred, reset anchor (anchors don’t cross lines)
                if "\n" in part_str:
                    self._anchor_idx = None

                # Budget update
                if "\n" in part_str:
                    last_line = part_str.split("\n")[-1]
                    full_budget = max(
                        0, self.MAX_LINE_LENGTH - indent_level * self.indent_size
                    )
                    indent_spaces = " " * (indent_level * self.indent_size)
                    used = (
                        (len(last_line) - len(indent_spaces))
                        if last_line.startswith(indent_spaces)
                        else len(last_line)
                    )
                    current_line_budget = max(0, full_budget - used)
                else:
                    current_line_budget = max(0, current_line_budget - len(part_str))

                # Advance i; if we looked ahead over LineSuffix nodes, skip them now
                if isinstance(part, doc.Line):
                    i = j
                else:
                    i += 1

            # End of concat: flush any tail suffixes at the anchor (or append)
            if self._suffix_queue:
                self._flush_suffix_into(result, default_append=True)

            self._anchor_idx = None
            self._anchor_idx = saved_anchor

            return "".join(result)

        elif isinstance(doc_node, doc.IfBreak):
            branch = doc_node.break_contents if is_broken else doc_node.flat_contents
            return self.format_doc_ir(branch, indent_level, width_remaining, is_broken)

        elif isinstance(doc_node, doc.Align):
            align_spaces = doc_node.n if doc_node.n is not None else self.indent_size
            extra_levels = align_spaces // self.indent_size
            child_indent_level = indent_level + extra_levels
            child_width_budget = max(0, width_remaining - align_spaces)
            return self.format_doc_ir(
                doc_node.contents,
                child_indent_level,
                child_width_budget,
                is_broken,
            )

        elif isinstance(doc_node, doc.LineSuffix):
            self._suffix_queue.append(doc_node.text)
            return ""

        else:
            raise ValueError(f"Unknown DocType: {type(doc_node)}")
