"""Pytorch Fix Pass."""

import ast as ast3
from copy import deepcopy
from typing import Optional, Sequence, TypeVar, cast

import jaclang.compiler.unitree as uni
from jaclang.compiler.constant import Tokens as Tok
from jaclang.compiler.passes import UniPass


T = TypeVar("T", bound=ast3.AST)


class PreDynamoPass(UniPass):
    """Pre-Dynamo pass for PyTorch."""

    def before_pass(self) -> None:
        """Before pass."""
        self.needs_gm_rt = False  # whether we need to import graphmend_runtime
        self._HOISTABLE_CALLS = {
            "print",
            "logging",
            "sys.stdout.write",
            "sys.stderr.write",
            "sys.stdout.flush",
            "sys.stderr.flush",
        }
        return super().before_pass()

    def enter_node(self, node: uni.UniNode) -> None:
        """Enter node."""
        super().enter_node(node)

    def exit_node(self, node: uni.UniNode) -> None:
        """Exit node."""
        super().exit_node(node)

    def gen_name(self, node: uni.UniNode, name: Tok, value: str) -> uni.Name:
        """Generate Name."""
        return uni.Name(
            name=name,
            value=value,
            orig_src=node.loc.orig_src,
            col_start=node.loc.col_start,
            col_end=0,
            line=node.loc.first_line,
            end_line=node.loc.last_line,
            pos_start=0,
            pos_end=0,
        )

    def replace_node(
        self,
        new_nodes: list[uni.UniNode] | uni.UniNode,
        old_node: uni.UniNode,
        attr: str,
    ) -> None:
        """Replace old node with new nodes in parent's body and kid lists."""
        parent = old_node.parent
        if isinstance(new_nodes, uni.UniNode):
            new_nodes.parent = parent
            if hasattr(parent, attr):
                lst = getattr(parent, attr)
                if old_node in lst:
                    idx = lst.index(old_node)
                    lst[idx] = new_nodes
            if hasattr(parent, "kid") and old_node in parent.kid:
                idx = parent.kid.index(old_node)
                parent.kid[idx] = new_nodes
        else:  # list of nodes
            for n in new_nodes:
                n.parent = parent
            if hasattr(parent, attr):
                lst = getattr(parent, attr)
                if old_node in lst:
                    idx = lst.index(old_node)
                    setattr(parent, attr, lst[:idx] + new_nodes + lst[idx + 1 :])
            if hasattr(parent, "kid") and old_node in parent.kid:
                idx = parent.kid.index(old_node)
                parent.kid = parent.kid[:idx] + new_nodes + parent.kid[idx + 1 :]

    def check_same_lhs(
        self, assign_a: uni.UniNode, assign_b: uni.UniNode
    ) -> Optional[uni.Name]:
        """Return the common LHS target if both are simple assignment with same target."""
        if not (
            isinstance(assign_a, uni.Assignment)
            and isinstance(assign_b, uni.Assignment)
        ):
            return None
        ta, tb = assign_a.target[0], assign_b.target[0]
        if not (isinstance(ta, uni.Name) and isinstance(tb, uni.Name)):
            return None
        if ta.value != tb.value:
            return None
        return ta  # common target

    def check_call(self, node: uni.ExprStmt) -> Optional[tuple]:
        """Return (target, name, tensor_expr, kwargs) if node is target(name, tensor_expr, **kwargs)."""
        if isinstance(node, uni.ExprStmt) and isinstance(node.expr, uni.FuncCall):
            call = node.expr
            if (
                isinstance(call.target, uni.AtomTrailer)
                and len(call.params) >= 2
                and isinstance(call.params[0], (uni.String, uni.MultiString))
                and isinstance(call.params[1], uni.Expr)
            ):
                name = (
                    call.params[0]
                    if isinstance(call.params[0], uni.String)
                    else call.params[0].strings[0]
                )
                tensor_expr = call.params[1]
                kwargs = (
                    {
                        kw.key._sym_name: kw.value
                        for kw in call.params[2:]
                        if isinstance(kw, uni.KWPair)
                    }
                    if len(call.params) > 2
                    else {}
                )
                return (call.target, name, tensor_expr, kwargs)
        return None

    def _is_io_call(self, node: uni.FuncCall) -> bool:
        """Check if a function call is an I/O operation that should be hoisted."""
        if isinstance(node.target, uni.Name):
            return node.target.value in self._HOISTABLE_CALLS
        elif isinstance(node.target, uni.AtomTrailer):
            parts = []
            current = node.target
            while isinstance(current, uni.AtomTrailer):
                if hasattr(current, "right") and isinstance(current.right, uni.Name):
                    parts.append(current.right.value)
                current = current.target
                if isinstance(current, uni.Name):
                    parts.append(current.value)

                return any(parts) in self._HOISTABLE_CALLS
        return False

    def _replace_io_call(self, node: uni.FuncCall) -> uni.FuncCall:
        """Return an I/O function call with a call to the hoisted version."""
        params = deepcopy(node.params)
        tuple_params = uni.TupleVal(values=cast(Sequence[uni.Expr], params), kid=params)
        io_name = node.target
        if isinstance(io_name, uni.Name):
            io_str = self.gen_name(node, Tok.STRING, f'"{io_name.value}"')
        else:
            io_str = self.gen_name(node, Tok.STRING, '"unknown_io"')
        lpr = self.gen_name(node, Tok.LPAREN, "(")
        rpr = self.gen_name(node, Tok.RPAREN, ")")
        dict_val = uni.DictVal(kv_pairs=[], kid=[lpr, rpr])
        args = [io_str, tuple_params, dict_val]
        gm_name = self.gen_name(node, Tok.NAME, "_gm_io")
        append_attr = self.gen_name(node, Tok.NAME, "append")
        func_name = uni.AtomTrailer(
            target=gm_name,
            right=append_attr,
            is_attr=True,
            is_null_ok=False,
            kid=[gm_name, append_attr],
        )
        return uni.FuncCall(
            target=func_name,
            params=args,
            genai_call=None,
            kid=[func_name] + args,
        )

    def _create_ability(self, node: uni.Ability) -> tuple:
        """Create ability node."""
        ability_name = f"__gm_core_{node.name_ref._sym_name}"
        name = self.gen_name(node, Tok.NAME, ability_name)
        name.py_ctx_func = ast3.Load
        kid = [name]
        ability = uni.Ability(
            name_ref=name,
            is_async=False,
            is_override=False,
            is_static=False,
            is_abstract=False,
            access=None,
            signature=deepcopy(node.signature),
            body=deepcopy(node.body),
            kid=kid,
        )

        call = uni.FuncCall(
            target=name,
            params=[],
            genai_call=None,
            kid=[name],
        )
        gm_ret, gm_io = self.gen_name(node, Tok.NAME, "_gm_ret"), self.gen_name(
            node, Tok.NAME, "_gm_io"
        )
        gm_ret.py_ctx_func = ast3.Store
        gm_io.py_ctx_func = ast3.Store
        assign_target = uni.TupleVal(values=[gm_ret, gm_io], kid=[gm_ret, gm_io])
        assign_target.name_spec.py_ctx_func = ast3.Store
        assign_expr = uni.Assignment(
            target=[assign_target],
            value=call,
            type_tag=None,
            kid=[assign_target, call],
        )

        gm_name = self.gen_name(node, Tok.NAME, "_gm_rt")
        flush_name = self.gen_name(node, Tok.NAME, "graphmend_flush")
        gm_name.py_ctx_func = ast3.Load
        flush_name.py_ctx_func = ast3.Load
        flush_func_name = uni.AtomTrailer(
            target=gm_name,
            right=flush_name,
            is_attr=True,
            is_null_ok=False,
            kid=[gm_name, flush_name],
        )
        gm_io_new = deepcopy(gm_io)
        gm_io_new.py_ctx_func = ast3.Load
        flush_call = uni.FuncCall(
            target=flush_func_name,
            params=[gm_io_new],
            genai_call=None,
            kid=[flush_func_name, gm_io_new],
        )
        flush_expr = uni.ExprStmt(expr=flush_call, in_fstring=False, kid=[flush_call])
        gm_ret_new = deepcopy(gm_ret)
        gm_ret_new.py_ctx_func = ast3.Load
        return_stmt = uni.ReturnStmt(expr=gm_ret_new, kid=[gm_ret_new])

        out_body_parts = (assign_expr, flush_expr, return_stmt)
        return (ability, out_body_parts)

    def exit_module(self, node: uni.Module) -> None:
        """Exit module."""
        if not self.needs_gm_rt:
            return
        imp_name = self.gen_name(node, Tok.NAME, "graphmend_runtime")
        imp_alias = self.gen_name(node, Tok.NAME, "_gm_rt")
        imp_alias.py_ctx_func = ast3.Store
        item = uni.ModuleItem(name=imp_name, alias=imp_alias, kid=[imp_name])
        imp = uni.Import(
            from_loc=None,
            items=[item],
            is_absorb=False,
            kid=[item],
        )
        node.body = [imp] + list(node.body)
        node.kid = [imp] + list(node.kid)

    def exit_ability(self, node: uni.Ability) -> None:
        """Exit ability."""
        if getattr(node, "is_hoistable", False):
            self.needs_gm_rt = True
            ability_node, out_body_parts = self._create_ability(node)
            if isinstance(node.body, list):
                body = node.body
            elif isinstance(node.body, uni.ImplDef) and isinstance(
                node.body.body, list
            ):
                body = node.body.body
            for i in body:
                if isinstance(i, uni.FuncCall) and self._is_io_call(i):
                    new_call = self._replace_io_call(i)
                    self.replace_node(new_call, i, "body")
            node.body = [ability_node, *out_body_parts]
            node.kid = [node.kid[0], ability_node, *out_body_parts]

    def exit_func_call(self, node: uni.FuncCall) -> None:
        """Exit function call."""
        if self._is_io_call(node):
            ability_node = node.find_parent_of_type(uni.Ability)
            if ability_node is not None:
                ability_node.is_hoistable = True  # type: ignore[attr-defined]

            new_func_call = self._replace_io_call(node)
            if isinstance(node.parent, uni.ExprStmt):
                node.parent.expr = new_func_call
                new_func_call.parent = node.parent
                if hasattr(node.parent, "kid") and node in node.parent.kid:
                    idx = node.parent.kid.index(node)
                    node.parent.kid[idx] = new_func_call

    def exit_if_stmt(self, node: uni.IfStmt) -> None:
        """Exit if statement."""
        a0 = node.body[0]
        new_node = None
        if node.else_body:
            b0 = node.else_body.body[0]
        else:
            return
        if isinstance(a0, uni.Assignment) and isinstance(b0, uni.Assignment):
            lhs = self.check_same_lhs(a0, b0)
            if lhs is not None:
                func_name = self.gen_name(node, Tok.NAME, "torch")
                attr_name = self.gen_name(node, Tok.NAME, "where")
                target = uni.AtomTrailer(
                    target=func_name,
                    right=attr_name,
                    is_attr=True,
                    is_null_ok=False,
                    kid=[func_name, attr_name],
                )
                call = uni.FuncCall(
                    target=target,
                    params=[
                        node.condition,
                        cast(uni.Expr, a0.value),
                        cast(uni.Expr, b0.value),
                    ],
                    genai_call=None,
                    kid=[target, node.condition, a0, b0],
                )
                new_node = uni.Assignment(
                    target=[lhs], value=call, type_tag=None, kid=[lhs, call]
                )
                self.replace_node(new_node, node, "body")

        elif isinstance(a0, uni.ReturnStmt) and isinstance(b0, uni.ReturnStmt):
            aexpr, bexpr = a0.expr, b0.expr
            if aexpr is None or bexpr is None:
                return
            func_name = self.gen_name(node, Tok.NAME, "torch")
            attr_name = self.gen_name(node, Tok.NAME, "where")
            target = uni.AtomTrailer(
                target=func_name,
                right=attr_name,
                is_attr=True,
                is_null_ok=False,
                kid=[func_name, attr_name],
            )
            call = uni.FuncCall(
                target=target,
                params=[node.condition, cast(uni.Expr, aexpr), cast(uni.Expr, bexpr)],
                genai_call=None,
                kid=[target, node.condition, a0, b0],
            )
            new_node = uni.ReturnStmt(expr=call, kid=[call])
            self.replace_node(new_node, node, "body")

        elif isinstance(a0, uni.ExprStmt) and isinstance(b0, uni.ExprStmt):
            a_reg = self.check_call(a0)
            b_reg = self.check_call(b0)
            if a_reg is not None and b_reg is not None:
                a_target, a_name, a_expr, a_kwargs = a_reg
                b_target, b_name, b_expr, b_kwargs = b_reg
                if a_name.value == b_name.value and set(a_kwargs.keys()) == set(
                    b_kwargs.keys()
                ):
                    tmp_name = self.gen_name(node, Tok.NAME, f"__{eval(a_name.value)}")
                    tmp_name.py_ctx_func = ast3.Store
                    func_name = self.gen_name(node, Tok.NAME, "torch")
                    attr_name = self.gen_name(node, Tok.NAME, "where")
                    target = uni.AtomTrailer(
                        target=func_name,
                        right=attr_name,
                        is_attr=True,
                        is_null_ok=False,
                        kid=[func_name, attr_name],
                    )
                    call = uni.FuncCall(
                        target=target,
                        params=[node.condition, a_expr, b_expr],
                        genai_call=None,
                        kid=[target, node.condition, a_expr, b_expr],
                    )
                    assign_node = uni.Assignment(
                        target=[tmp_name],
                        value=call,
                        type_tag=None,
                        kid=[tmp_name, call],
                    )

                    kwargs_nodes = [
                        uni.KWPair(
                            name := self.gen_name(node, Tok.NAME, k), v, [name, v]
                        )
                        for k, v in a_kwargs.items()
                    ]
                    param_name = self.gen_name(
                        node, Tok.NAME, f"__{eval(a_name.value)}"
                    )
                    reg_call = uni.FuncCall(
                        target=a_target,
                        params=[a_name, param_name] + kwargs_nodes,
                        genai_call=None,
                        kid=[a_target, a_name, param_name] + kwargs_nodes,
                    )
                    reg_node = uni.ExprStmt(
                        expr=reg_call, in_fstring=False, kid=[reg_call]
                    )
                    self.replace_node([assign_node, reg_node], node, "body")
