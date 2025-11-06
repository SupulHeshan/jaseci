# Generated from JavaScriptParser.g4 by ANTLR 4.13.1
from antlr4 import ParseTreeListener
from antlr4.tree.Tree import ParseTree
from typing import Any, Optional, Union, cast

from jaclang.compiler.passes.ecmascript.estree import (
    Program,
    Statement,
    ModuleDeclaration,
    Expression,
    BlockStatement,
    ExpressionStatement,
    VariableDeclaration,
    VariableDeclarator,
    FunctionDeclaration,
    ClassDeclaration,
    Identifier,
    Literal,
    ArrayExpression,
    ObjectExpression,
    FunctionExpression,
    ArrowFunctionExpression,
    UnaryExpression,
    BinaryExpression,
    LogicalExpression,
    MemberExpression,
    CallExpression,
    NewExpression,
    ThisExpression,
    Property,
    ClassBody,
    MethodDefinition,
    AssignmentExpression,
    UpdateExpression,
    IfStatement,
    WhileStatement,
    DoWhileStatement,
    ForStatement,
    BreakStatement,
    ContinueStatement,
    ReturnStatement,
    ImportDeclaration,
    ImportSpecifier,
    ExportNamedDeclaration,
    ExportDefaultDeclaration,
    SourceLocation,
    Position,
    ClassExpression,
)

if "." in __name__:
    from .JavaScriptParser import JavaScriptParser
else:
    from JavaScriptParser import JavaScriptParser


# This class defines a complete listener for a parse tree produced by JavaScriptParser.
class JavaScriptParserListener(ParseTreeListener):
    def __init__(self):
        self.ast: Optional[Program] = None
        self.node_stack: list[Any] = []

    # Add node attribute to all contexts that need it
    # Initialize node attribute for all necessary context types
    setattr(JavaScriptParser.StatementContext, "node", None)
    setattr(JavaScriptParser.AdditiveExpressionContext, "node", None)
    setattr(JavaScriptParser.MultiplicativeExpressionContext, "node", None)
    setattr(JavaScriptParser.LogicalAndExpressionContext, "node", None)
    setattr(JavaScriptParser.LogicalOrExpressionContext, "node", None)
    setattr(JavaScriptParser.UnaryPlusExpressionContext, "node", None)
    setattr(JavaScriptParser.UnaryMinusExpressionContext, "node", None)
    setattr(JavaScriptParser.BitNotExpressionContext, "node", None)
    setattr(JavaScriptParser.NotExpressionContext, "node", None)
    setattr(JavaScriptParser.ArrayElementContext, "node", None)
    setattr(JavaScriptParser.PropertyExpressionAssignmentContext, "node", None)
    setattr(JavaScriptParser.PropertyAssignmentContext, "node", None)
    setattr(JavaScriptParser.PropertyNameContext, "node", None)

    def _get_location(self, ctx: Any) -> Optional[SourceLocation]:
        """Get source location from context."""
        if not (hasattr(ctx, "start") and hasattr(ctx, "stop")):
            return None

        return SourceLocation(
            source=None,
            start=Position(line=ctx.start.line, column=ctx.start.column),
            end=Position(line=ctx.stop.line, column=ctx.stop.column),
        )

    def _current_node(self) -> Any:
        """Get the current node from the stack."""
        return self.node_stack[-1] if self.node_stack else None

    def _ensure_node_attr(self, ctx: Any) -> None:
        """Ensure the context has a node attribute."""
        if not hasattr(ctx, "node"):
            setattr(ctx, "node", None)

    def _get_node(self, ctx: Any) -> Optional[Any]:
        """Safely get the node attribute from a context."""
        return getattr(ctx, "node", None)

    def _set_node(self, ctx: Any, node: Any) -> None:
        """Safely set the node attribute on a context."""
        self._ensure_node_attr(ctx)
        setattr(ctx, "node", node)

    # Enter a parse tree produced by JavaScriptParser#program.
    def enterProgram(self, ctx: JavaScriptParser.ProgramContext):
        program = Program(body=[], sourceType="module", loc=self._get_location(ctx))
        self.ast = program
        self.node_stack.append(program)

    # Exit a parse tree produced by JavaScriptParser#program.
    def exitProgram(self, ctx: JavaScriptParser.ProgramContext):
        prog = self.node_stack.pop()
        print(prog)

    # Enter a parse tree produced by JavaScriptParser#sourceElement.
    def enterSourceElement(self, ctx: JavaScriptParser.SourceElementContext):
        pass

    def exitSourceElement(self, ctx: JavaScriptParser.SourceElementContext):
        if ctx.statement():
            current = self._current_node()
            if isinstance(current, Program):
                statement_node = self._get_node(ctx.statement())
                if statement_node is not None:
                    current.body.append(statement_node)

    # Enter a parse tree produced by JavaScriptParser#statement.
    def enterStatement(self, ctx: JavaScriptParser.StatementContext):
        pass

    def exitStatement(self, ctx: JavaScriptParser.StatementContext):
        # Store the result on the context for parent nodes to access
        if ctx.children and hasattr(ctx.children[0], "node"):
            self._set_node(ctx, self._get_node(ctx.children[0]))

    # Enter a parse tree produced by JavaScriptParser#block.
    def enterBlock(self, ctx: JavaScriptParser.BlockContext):
        block = BlockStatement(body=[], loc=self._get_location(ctx))
        self.node_stack.append(block)

    def exitBlock(self, ctx: JavaScriptParser.BlockContext):
        block = self.node_stack.pop()
        self._set_node(ctx, block)

    # Enter a parse tree produced by JavaScriptParser#variableStatement.
    def enterVariableStatement(self, ctx: JavaScriptParser.VariableStatementContext):
        # The variable kind (var, let, const) is part of the child nodes
        # We need to look at variableDeclarationList.varModifier
        decl_list = ctx.variableDeclarationList()
        kind = (
            decl_list.children[0].getText()
            if decl_list and decl_list.children
            else "var"
        )

        decl = VariableDeclaration(
            declarations=[], kind=kind, loc=self._get_location(ctx)
        )
        self.node_stack.append(decl)

    def exitVariableStatement(self, ctx: JavaScriptParser.VariableStatementContext):
        decl = self.node_stack.pop()
        self._set_node(ctx, decl)

    # Enter a parse tree produced by JavaScriptParser#variableDeclaration.
    def enterVariableDeclaration(
        self, ctx: JavaScriptParser.VariableDeclarationContext
    ):
        # Create empty declarator that will be populated in exit
        declarator = VariableDeclarator(id=None, init=None, loc=self._get_location(ctx))
        self.node_stack.append(declarator)

    def exitVariableDeclaration(self, ctx: JavaScriptParser.VariableDeclarationContext):
        declarator = self.node_stack.pop()

        # Find the identifier and initializer if present
        if ctx.children:
            # First child should be the assignable (identifier)
            if hasattr(ctx.children[0], "node"):
                declarator.id = ctx.children[0].node

            # Check for initializer (after equals sign)
            if len(ctx.children) > 2 and hasattr(ctx.children[2], "node"):
                declarator.init = ctx.children[2].node

        current = self._current_node()
        if isinstance(current, VariableDeclaration):
            current.declarations.append(declarator)
        setattr(ctx, "node", declarator)

    # Enter a parse tree produced by JavaScriptParser#identifier.
    def exitAssignable(self, ctx):
        # Get the identifier name from the assignable context
        identifier = ctx.children[0].getText() if ctx.children else None
        if identifier:
            setattr(
                ctx, "node", Identifier(name=identifier, loc=self._get_location(ctx))
            )

    def enterIdentifier(self, ctx: JavaScriptParser.IdentifierContext):
        pass

    def exitIdentifier(self, ctx: JavaScriptParser.IdentifierContext):
        setattr(
            ctx, "node", Identifier(name=ctx.getText(), loc=self._get_location(ctx))
        )

    # Expressions

    def exitLiteralExpression(self, ctx: JavaScriptParser.LiteralExpressionContext):
        value = ctx.literal().getText()
        if value in ["true", "false"]:
            value = value == "true"
        elif value == "null":
            value = None
        else:
            try:
                value = int(value)
            except ValueError:
                try:
                    value = float(value)
                except ValueError:
                    # Strip quotes for strings
                    value = value[1:-1] if value[0] in ['"', "'"] else value

        ctx.node = Literal(value=value, raw=ctx.getText(), loc=self._get_location(ctx))

    def exitArrayElement(self, ctx: JavaScriptParser.ArrayElementContext):
        if hasattr(ctx, "singleExpression"):
            expr = self._get_node(ctx.singleExpression())
            if expr is not None:
                self._set_node(ctx, expr)

    def exitArrayLiteralExpression(
        self, ctx: JavaScriptParser.ArrayLiteralExpressionContext
    ):
        elements = []
        if ctx.arrayLiteral().elementList():
            for elem in ctx.arrayLiteral().elementList().arrayElement():
                elements.append(self._get_node(elem))
        ctx.node = ArrayExpression(elements=elements, loc=self._get_location(ctx))

    def exitPropertyName(self, ctx: JavaScriptParser.PropertyNameContext):
        # Handle different types of property names (identifier, string, number, computed)
        if ctx.identifierName():
            name_node = Identifier(
                name=ctx.identifierName().getText(), loc=self._get_location(ctx)
            )
        elif ctx.StringLiteral():
            text = ctx.StringLiteral().getText()
            # Strip quotes
            text = text[1:-1] if text[0] in ['"', "'"] else text
            name_node = Literal(
                value=text,
                raw=ctx.StringLiteral().getText(),
                loc=self._get_location(ctx),
            )
        else:
            # Default to using the text as is
            name_node = Literal(
                value=ctx.getText(), raw=ctx.getText(), loc=self._get_location(ctx)
            )
        self._set_node(ctx, name_node)

    def exitPropertyExpressionAssignment(
        self, ctx: JavaScriptParser.PropertyExpressionAssignmentContext
    ):
        key = self._get_node(ctx.propertyName())
        value = self._get_node(ctx.singleExpression())
        if key is not None and value is not None:
            self._set_node(
                ctx,
                Property(
                    key=key,
                    value=value,
                    kind="init",
                    method=False,
                    shorthand=False,
                    computed=False,
                    loc=self._get_location(ctx),
                ),
            )

    def exitObjectLiteralExpression(
        self, ctx: JavaScriptParser.ObjectLiteralExpressionContext
    ):
        properties = []
        if ctx.objectLiteral().propertyAssignment():
            for prop in ctx.objectLiteral().propertyAssignment():
                node = self._get_node(prop)
                if node is not None:
                    properties.append(node)
        ctx.node = ObjectExpression(properties=properties, loc=self._get_location(ctx))

    # Binary expressions
    def exitAdditiveExpression(
        self, ctx: JavaScriptParser.AdditiveExpressionContext
    ) -> None:
        if len(ctx.children) >= 3:  # Should have left, operator, right
            left = ctx.children[0]  # type: ParseTree
            op = str(ctx.children[1].getText())
            right = ctx.children[2]  # type: ParseTree

            left_node = self._get_node(left)
            right_node = self._get_node(right)
            if left_node is not None and right_node is not None:
                self._set_node(
                    ctx,
                    BinaryExpression(
                        operator=op,
                        left=left_node,
                        right=right_node,
                        loc=self._get_location(ctx),
                    ),
                )

    def exitMultiplicativeExpression(
        self, ctx: JavaScriptParser.MultiplicativeExpressionContext
    ) -> None:
        if len(ctx.children) >= 3:  # Should have left, operator, right
            left: ParseTree = ctx.children[0]
            op: str = str(ctx.children[1].getText())
            right: ParseTree = ctx.children[2]

            if hasattr(left, "node") and hasattr(right, "node"):
                setattr(
                    ctx,
                    "node",
                    BinaryExpression(
                        operator=op,
                        left=left.node,  # type: ignore
                        right=right.node,  # type: ignore
                        loc=self._get_location(ctx),
                    ),
                )

    def exitLogicalAndExpression(
        self, ctx: JavaScriptParser.LogicalAndExpressionContext
    ):
        left_expr = self._get_node(ctx.singleExpression(0))
        right_expr = self._get_node(ctx.singleExpression(1))
        if left_expr is not None and right_expr is not None:
            self._set_node(
                ctx,
                LogicalExpression(
                    operator="&&",
                    left=left_expr,
                    right=right_expr,
                    loc=self._get_location(ctx),
                ),
            )

    def exitLogicalOrExpression(self, ctx: JavaScriptParser.LogicalOrExpressionContext):
        left_expr = self._get_node(ctx.singleExpression(0))
        right_expr = self._get_node(ctx.singleExpression(1))
        if left_expr is not None and right_expr is not None:
            self._set_node(
                ctx,
                LogicalExpression(
                    operator="||",
                    left=left_expr,
                    right=right_expr,
                    loc=self._get_location(ctx),
                ),
            )

    def exitUnaryPlusExpression(self, ctx: JavaScriptParser.UnaryPlusExpressionContext):
        expr = self._get_node(ctx.singleExpression())
        if expr is not None:
            self._set_node(
                ctx,
                UnaryExpression(
                    operator="+",
                    argument=expr,
                    prefix=True,
                    loc=self._get_location(ctx),
                ),
            )

    def exitUnaryMinusExpression(
        self, ctx: JavaScriptParser.UnaryMinusExpressionContext
    ):
        expr = self._get_node(ctx.singleExpression())
        if expr is not None:
            self._set_node(
                ctx,
                UnaryExpression(
                    operator="-",
                    argument=expr,
                    prefix=True,
                    loc=self._get_location(ctx),
                ),
            )

    def exitBitNotExpression(self, ctx: JavaScriptParser.BitNotExpressionContext):
        expr = self._get_node(ctx.singleExpression())
        if expr is not None:
            self._set_node(
                ctx,
                UnaryExpression(
                    operator="~",
                    argument=expr,
                    prefix=True,
                    loc=self._get_location(ctx),
                ),
            )

    def exitNotExpression(self, ctx: JavaScriptParser.NotExpressionContext):
        expr = self._get_node(ctx.singleExpression())
        if expr is not None:
            self._set_node(
                ctx,
                UnaryExpression(
                    operator="!",
                    argument=expr,
                    prefix=True,
                    loc=self._get_location(ctx),
                ),
            )

    # Function declarations and expressions

    def exitFunctionDeclaration(self, ctx: JavaScriptParser.FunctionDeclarationContext):
        params = []
        if ctx.formalParameterList():
            for param in ctx.formalParameterList().formalParameterArg():
                node = self._get_node(param)
                if node is not None:
                    params.append(node)

        id_node = self._get_node(ctx.identifier())
        body_node = self._get_node(ctx.functionBody())
        if id_node is not None and body_node is not None:
            self._set_node(
                ctx,
                FunctionDeclaration(
                    id=id_node,
                    params=params,
                    body=body_node,
                    generator=bool(ctx.Star),
                    async_=bool(ctx.Async),
                    loc=self._get_location(ctx),
                ),
            )

    def exitFunctionExpression(self, ctx: JavaScriptParser.FunctionExpressionContext):
        # Get the anonymous function from the context
        anon_func = (
            ctx.anonymousFunction() if hasattr(ctx, "anonymousFunction") else None
        )
        if not anon_func:
            return

        params: list[Any] = []
        # Get parameters from the anonymous function
        param_list = getattr(anon_func, "formalParameterList", lambda: None)()
        if param_list is not None:
            param_args = getattr(param_list, "formalParameterArg", lambda: [])()
            if param_args:
                for param in param_args:
                    node = self._get_node(param)
                    if node is not None:
                        params.append(node)

        # Get the function body from anonymous function
        body_node = None
        fn_body = getattr(anon_func, "functionBody", lambda: None)()
        if fn_body is not None:
            body_node = self._get_node(fn_body)

        # Create function expression node
        if body_node is not None:
            self._set_node(
                ctx,
                FunctionExpression(
                    id=None,  # Anonymous functions don't have identifiers
                    params=params,
                    body=body_node,
                    generator=bool(getattr(anon_func, "Star", False)),
                    async_=bool(getattr(anon_func, "Async", False)),
                    loc=self._get_location(ctx),
                ),
            )

    def exitArrowFunction(self, ctx: JavaScriptParser.ArrowFunctionContext):
        params = []
        if isinstance(ctx.arrowFunctionParameters(), list):
            for param in ctx.arrowFunctionParameters():
                node = self._get_node(param)
                if node is not None:
                    params.append(node)
        else:
            node = self._get_node(ctx.arrowFunctionParameters())
            if node is not None:
                params.append(node)

        body = self._get_node(ctx.arrowFunctionBody())
        if body is not None:
            self._set_node(
                ctx,
                ArrowFunctionExpression(
                    params=params,
                    body=body,
                    expression=not isinstance(body, BlockStatement),
                    async_=bool(ctx.Async),
                    loc=self._get_location(ctx),
                ),
            )

    # Class declarations and expressions

    def exitClassDeclaration(self, ctx: JavaScriptParser.ClassDeclarationContext):
        id_node = self._get_node(ctx.identifier())
        class_tail = ctx.classTail()
        super_class = None
        body_node = None

        if class_tail and hasattr(class_tail, "children"):
            # Look for extends clause and class body in children
            for i, child in enumerate(class_tail.children):
                # Find superclass (after extends token)
                if (
                    hasattr(child, "symbol")
                    and child.getText() == "extends"
                    and i + 1 < len(class_tail.children)
                ):
                    super_class = self._get_node(class_tail.children[i + 1])
                # Find class body
                if hasattr(child, "node"):
                    node = self._get_node(child)
                    if isinstance(node, ClassBody):
                        body_node = node

        if id_node is not None and body_node is not None:
            self._set_node(
                ctx,
                ClassDeclaration(
                    id=id_node,
                    superClass=super_class,
                    body=body_node,
                    loc=self._get_location(ctx),
                ),
            )

    def exitClassExpression(self, ctx: JavaScriptParser.ClassExpressionContext):
        id_node = self._get_node(ctx.identifier()) if ctx.identifier() else None
        class_tail = ctx.classTail()
        super_class = None
        body_node = None

        if class_tail and hasattr(class_tail, "children"):
            # Look for extends clause and class body in children
            for i, child in enumerate(class_tail.children):
                # Find superclass (after extends token)
                if (
                    hasattr(child, "symbol")
                    and child.getText() == "extends"
                    and i + 1 < len(class_tail.children)
                ):
                    super_class = self._get_node(class_tail.children[i + 1])
                # Find class body
                if hasattr(child, "node"):
                    node = self._get_node(child)
                    if isinstance(node, ClassBody):
                        body_node = node

        if body_node is not None:
            self._set_node(
                ctx,
                ClassExpression(
                    id=id_node,
                    superClass=super_class,
                    body=body_node,
                    loc=self._get_location(ctx),
                ),
            )

    # Basic node types already implemented

    def exitClassBody(self, ctx):
        body = []
        for elem in ctx.classElement():
            node = self._get_node(elem)
            if node is not None:
                body.append(node)
        self._set_node(ctx, ClassBody(body=body, loc=self._get_location(ctx)))

    def exitMethodDeclaration(self, ctx):
        body_node = self._get_node(ctx.functionBody()) if ctx.functionBody() else None

        value = FunctionExpression(
            id=None,
            params=[],
            body=body_node,
            generator=False,
            async_=False,
            loc=self._get_location(ctx),
        )

        key_node = (
            self._get_node(ctx.identifierName()) if ctx.identifierName() else None
        )

        self._set_node(
            ctx,
            MethodDefinition(
                key=key_node,
                value=value,
                kind="method",
                computed=False,
                static=False,
                loc=self._get_location(ctx),
            ),
        )

    def exitParenthesizedExpression(self, ctx):
        # Transfer the node from the inner expression
        if ctx.children and len(ctx.children) > 1:
            inner_expr = ctx.children[1]  # Skip the opening paren
            inner_node = self._get_node(inner_expr)
            if inner_node is not None:
                self._set_node(ctx, inner_node)

    def exitSingleExpression(self, ctx):
        # If we don't already have a node, try to get it from the first child
        if not self._get_node(ctx) and ctx.children:
            child = ctx.children[0]
            child_node = self._get_node(child)
            if child_node is not None:
                self._set_node(ctx, child_node)
