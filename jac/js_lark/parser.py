from jaclang.vendor.lark import Lark, Transformer, v_args, Token
import json

# Comprehensive JavaScript Grammar based on ANTLR grammars-v4
javascript_grammar = r"""
    ?start: program

    program: hashbang_line? source_elements? 
    
    hashbang_line: HASHBANG
    
    source_elements: source_element+
    
    ?source_element: statement
    
    ?statement: function_declaration
              | class_declaration
              | block
              | variable_statement
              | import_statement
              | export_statement
              | empty_statement
              | if_statement
              | iteration_statement
              | continue_statement
              | break_statement
              | return_statement
              | with_statement
              | labelled_statement
              | switch_statement
              | throw_statement
              | try_statement
              | debugger_statement
              | expression_statement

    // Expression statements 
    expression_statement: expression_sequence eos

    block: "{" statement_list? "}"
    
    statement_list: statement+
    
    // Variable declarations
    variable_statement: variable_declaration_list eos
    
    variable_declaration_list: var_modifier variable_declaration ("," variable_declaration)*
    
    variable_declaration: assignable ("=" single_expression)?
    
    var_modifier: VAR | LET | CONST
    
    ?assignable: identifier
               | array_literal
               | object_literal
    
    // Import/Export
    import_statement: "import" import_from_block
    
    import_from_block: import_default? (import_namespace | import_module_items) import_from eos
                     | STRING eos
    
    import_module_items: "{" (import_alias_name ",")* (import_alias_name ","?)? "}"
    
    import_alias_name: module_export_name ("as" imported_binding)?
    
    module_export_name: identifier_name | STRING
    
    imported_binding: IDENTIFIER | "yield" | "await"
    
    import_default: alias_name ","
    
    import_namespace: ("*" | identifier_name) ("as" identifier_name)?
    
    import_from: "from" STRING
    
    alias_name: identifier_name ("as" identifier_name)?
    
    export_statement: "export" "default"? (export_from_block | declaration) eos  -> export_declaration
                    | "export" "default" single_expression eos                     -> export_default_declaration
    
    export_from_block: import_module_items import_from?
                     | export_namespace import_from
    
    export_namespace: ("*" | identifier_name) ("as" identifier_name)?
    
    declaration: variable_statement
               | class_declaration  
               | function_declaration
    
    // Function declarations - must have an identifier (name) - HIGH PRIORITY
    function_declaration.2: ASYNC? "function" "*"? identifier "(" formal_parameter_list? ")" function_body
    
    formal_parameter_list: formal_parameter_arg ("," formal_parameter_arg)* ("," last_formal_parameter_arg)?
                         | last_formal_parameter_arg
    
    formal_parameter_arg: assignable ("=" single_expression)?
    
    last_formal_parameter_arg: "..." single_expression
    
    function_body: "{" source_elements? "}"
    
    // Arrow functions
    arrow_function: ASYNC? arrow_function_parameters "=>" arrow_function_body
    
    arrow_function_parameters: identifier
                             | "(" formal_parameter_list? ")"
    
    arrow_function_body: single_expression
                       | function_body
    
    // Class declarations - separate from expressions
    class_declaration: "class" identifier class_tail
    
    class_tail: ("extends" single_expression)? "{" class_element* "}"
    
    class_element: ("static" | "async")? method_definition
                 | ("static" | "async")? property_name ("=" single_expression)? ";"?
                 | empty_statement
    
    method_definition: "*"? property_name "(" formal_parameter_list? ")" function_body
                     | (GET | SET) property_name "(" formal_parameter_list? ")" function_body
    
    // Control flow
    empty_statement: ";"
    
    if_statement: "if" "(" expression_sequence ")" statement ("else" statement)?
    
    iteration_statement: "do" statement "while" "(" expression_sequence ")" eos                                                    -> do_statement
                       | "while" "(" expression_sequence ")" statement                                                             -> while_statement
                       | "for" "(" (expression_sequence | variable_declaration_list)? ";" expression_sequence? ";" expression_sequence? ")" statement -> for_statement
                       | "for" "(" (single_expression | variable_declaration_list) "in" expression_sequence ")" statement         -> for_in_statement
                       | "for" "await"? "(" (single_expression | variable_declaration_list) "of" expression_sequence ")" statement -> for_of_statement
    
    continue_statement: "continue" identifier? eos
    
    break_statement: "break" identifier? eos
    
    return_statement: "return" expression_sequence? eos
    
    with_statement: "with" "(" expression_sequence ")" statement
    
    switch_statement: "switch" "(" expression_sequence ")" case_block
    
    case_block: "{" case_clauses? (default_clause case_clauses?)? "}"
    
    case_clauses: case_clause+
    
    case_clause: "case" expression_sequence ":" statement_list?
    
    default_clause: "default" ":" statement_list?
    
    labelled_statement: identifier ":" statement
    
    throw_statement: "throw" expression_sequence eos
    
    try_statement: "try" block (catch_production finally_production? | finally_production)
    
    catch_production: "catch" ("(" assignable? ")")? block
    
    finally_production: "finally" block
    
    debugger_statement: "debugger" eos
    
    // Expressions
    expression_sequence: single_expression ("," single_expression)*
    
    ?single_expression: assignment_expression
    
    ?assignment_expression: arrow_function
                          | conditional_expression (assignment_operator assignment_expression)?
    
    assignment_operator: "=" | "*=" | "/=" | "%=" | "+=" | "-=" 
                       | "<<=" | ">>=" | ">>>="
                       | "&=" | "^=" | "|=" | "**="
    
    // Function expressions - identifier is optional for anonymous functions - LOWER PRIORITY
    function_expression.1: ASYNC? "function" "*"? identifier? "(" formal_parameter_list? ")" function_body
    
    class_expression: "class" identifier? class_tail
    
    ?conditional_expression: logical_or_expression ("?" single_expression ":" single_expression)?
    
    logical_or_expression: logical_and_expression (logical_or_op logical_and_expression)*
    logical_or_op: "||"
    
    logical_and_expression: bitwise_or_expression (logical_and_op bitwise_or_expression)*
    logical_and_op: "&&"
    
    bitwise_or_expression: bitwise_xor_expression (bitwise_or_op bitwise_xor_expression)*
    bitwise_or_op: "|"
    
    bitwise_xor_expression: bitwise_and_expression (bitwise_xor_op bitwise_and_expression)*
    bitwise_xor_op: "^"
    
    bitwise_and_expression: equality_expression (bitwise_and_op equality_expression)*
    bitwise_and_op: "&"
    
    equality_expression: relational_expression (equality_op relational_expression)*
    equality_op: "===" -> eq_strict_eq
               | "!==" -> eq_strict_neq
               | "==" -> eq_eq
               | "!=" -> eq_neq
    
    relational_expression: shift_expression (relational_op shift_expression)*
    relational_op: "<=" -> rel_lte
                 | ">=" -> rel_gte
                 | "<" -> rel_lt
                 | ">" -> rel_gt
                 | "instanceof" -> rel_instanceof
                 | "in" -> rel_in
    
    shift_expression: additive_expression (shift_op additive_expression)*
    shift_op: "<<" -> shift_left
            | ">>>" -> shift_right_unsigned
            | ">>" -> shift_right
    
    additive_expression: multiplicative_expression (additive_op multiplicative_expression)*
    additive_op: "+" -> add_plus
               | "-" -> add_minus
    
    multiplicative_expression: exponentiation_expression (mult_op exponentiation_expression)*
    mult_op: "*" -> mult_star
           | "/" -> mult_slash
           | "%" -> mult_percent
    
    ?exponentiation_expression: unary_expression ("**" exponentiation_expression)?
    
    ?unary_expression: ("delete" | "void" | "typeof" | "++"|"--" | "+"|"-" | "~" | "!") unary_expression
                     | AWAIT unary_expression
                     | yield_expression
                     | postfix_expression
    
    yield_expression: "yield" ("*"? single_expression)?
    
    postfix_expression: member_expression postfix_op?
    
    postfix_op: "++" -> postfix_increment
              | "--" -> postfix_decrement
    
    ?member_expression: primary_expression
                      | member_expression "[" expression_sequence "]"  -> member_expr_computed
                      | member_expression "." identifier_name          -> member_expr_property
                      | member_expression arguments                    -> member_expr_call
                      | "new" member_expression arguments              -> member_expr_new
                      | "super"                                        -> member_expr_super
    
    arguments: "(" (single_expression ("," single_expression)*)? ")"
    
    ?primary_expression: "this"
                       | identifier
                       | literal
                       | array_literal
                       | object_literal
                       | "(" expression_sequence ")"
                       | function_expression
                       | class_expression
    
    // Literals
    ?literal: "null"                    -> null_literal
            | "true"                    -> boolean_literal
            | "false"                   -> boolean_literal  
            | NUMBER                    -> numeric_literal
            | STRING                    -> string_literal
            | template_string_literal
            | REGEX                     -> regex_literal
    
    array_literal: "[" element_list? "]"
    
    element_list: ","* array_element ("," ","* array_element)* ","*
    
    array_element: "..." single_expression  -> spread_element
                 | single_expression        -> array_element_expr
    
    object_literal: "{" (property_assignment ("," property_assignment)* ","?)? "}"
    
    property_assignment: property_name ":" single_expression            -> property_expression_assignment
                       | "[" single_expression "]" ":" single_expression -> computed_property_expression_assignment
                       | (GET | SET) property_name "(" formal_parameter_list? ")" function_body -> property_getter_setter
                       | ASYNC? "*"? property_name "(" formal_parameter_list? ")" function_body            -> method_property  
                       | identifier                                                                  -> property_shorthand
                       | "..." single_expression                                                     -> rest_parameter
    
    property_name: identifier_name
                 | STRING
                 | NUMBER
    
    template_string_literal: TEMPLATE_STRING_START template_string_atom* TEMPLATE_STRING_END
    
    template_string_atom: TEMPLATE_STRING_ATOM
                        | TEMPLATE_STRING_EXPR_START expression_sequence "}"
    
    // Identifiers and names
    identifier: IDENTIFIER
             | contextual_keyword
    
    contextual_keyword: "async" | "await" | "yield"
                     | "let" | "as" | "of"
                     | "get" | "set" | "static"
    
    ?identifier_name: IDENTIFIER
                    | "async" | "await" | "yield" 
                    | "let" | "const" | "var"
                    | "from" | "as" | "of" | "in"
                    | "get" | "set" | "static"
                    | "instanceof" | CONSTRUCTOR
    
    // End of statement - semicolon or newline required
    eos: ";" | _NEWLINE
    
    // Priority order: explicit terminals > identifiers
    VAR.2: "var"
    LET.2: "let"
    CONST.2: "const"
    ASYNC.2: "async"
    AWAIT.2: "await"
    GET.2: "get"
    SET.2: "set"
    CONSTRUCTOR.3: "constructor"
    HASHBANG: /#!.*/
    IDENTIFIER: /[a-zA-Z_$][a-zA-Z0-9_$]*/
    NUMBER: /0[xX][0-9a-fA-F]+/               // Hex
          | /0[oO][0-7]+/                     // Octal
          | /0[bB][01]+/                      // Binary  
          | /\d+\.?\d*([eE][+-]?\d+)?/        // Decimal
    
    STRING: /"([^"\\]|\\(.|\n))*"/
          | /'([^'\\]|\\(.|\n))*'/
    
    REGEX: /\/(?![*\/])([^\/\\\n\[]|\\[^\n]|\[([^\]\\\n]|\\[^\n])*\])+\/[gimsuvy]*/
    
    TEMPLATE_STRING_START: /`/
    TEMPLATE_STRING_END: /`/
    TEMPLATE_STRING_ATOM: /([^`$\\]|\\.)+/
    TEMPLATE_STRING_EXPR_START: /\$\{/
    
    _NEWLINE: /\n/

    %import common.WS
    %ignore WS
    %ignore /\/\/.*/
    %ignore /\/\*(.|\n)*?\*\//
"""

# Transformer to convert parse tree to AST
@v_args(inline=True)
class JSTransformer(Transformer):
    def program(self, *args):
        hashbang = args[0] if args and isinstance(args[0], dict) and args[0].get("type") == "HashBang" else None
        source_elements = args[-1] if args and isinstance(args[-1], dict) and args[-1].get("type") == "SourceElements" else None
        return {
            "type": "Program",
            "hashbang": hashbang,
            "body": source_elements["elements"] if source_elements else []
        }
    
    def hashbang_line(self, line):
        return {"type": "HashBang", "value": str(line)}
    
    def source_elements(self, *elements):
        return {"type": "SourceElements", "elements": list(elements)}
    
    def block(self, *statements):
        # statements might be a single list from statement_list, or multiple statements
        if len(statements) == 1 and isinstance(statements[0], list):
            return {"type": "BlockStatement", "body": statements[0]}
        return {"type": "BlockStatement", "body": list(statements) if statements else []}
    
    def statement_list(self, *statements):
        return list(statements)
    
    # Variable declarations
    def variable_statement(self, decl_list, _eos):
        return decl_list
    
    def variable_declaration_list(self, modifier, *declarations):
        return {
            "type": "VariableDeclaration",
            "kind": str(modifier),
            "declarations": list(declarations)
        }
    
    def variable_declaration(self, assignable, *init):
        # Filter out the "=" token (keep_all_tokens includes it)
        init_value = None
        for item in init:
            if not isinstance(item, Token):  # Skip tokens, keep the expression
                init_value = item
                break
        return {
            "type": "VariableDeclarator",
            "id": assignable,
            "init": init_value
        }
    
    @v_args(tree=True)
    def var_modifier(self, tree):
        # Get the actual token value from tree children
        if tree.children:
            return str(tree.children[0])
        return "var"  # Default fallback
    
    # Functions
    def function_declaration(self, *args):
        # The args contain only the transformed nodes, not the literal tokens
        # Grammar: ASYNC? "function" "*"? identifier "(" formal_parameter_list? ")" function_body
        # But args only contain: [identifier, params?, body] or [async_token, identifier, params?, body]
        
        async_idx = 0
        is_async = False
        if args and isinstance(args[0], Token) and args[0].type == "ASYNC":
            is_async = True
            async_idx = 1
        
        # The next argument should be the identifier (function name)
        name = None
        current_idx = async_idx
        if current_idx < len(args) and isinstance(args[current_idx], dict) and args[current_idx].get("type") == "Identifier":
            name = args[current_idx]
            current_idx += 1
        
        # Check if we have generator function (look for generator flag in name or separate token)
        is_generator = False
        # For now, assume non-generator (we'll handle generator functions separately)
        
        # Find params and body
        params = {"type": "Parameters", "params": []}
        body = args[-1]  # Body is always last
        
        # Look for parameters
        for i in range(current_idx, len(args) - 1):  # Exclude the last element (body)
            if isinstance(args[i], dict) and args[i].get("type") == "Parameters":
                params = args[i]
                break
        
        # Find params and body
        params = {"type": "Parameters", "params": []}
        body = args[-1]
        
        for i in range(current_idx, len(args)):
            if isinstance(args[i], dict) and args[i].get("type") == "Parameters":
                params = args[i]
                break
        
        return {
            "type": "FunctionDeclaration",
            "id": name,
            "params": params["params"],
            "body": body,
            "async": is_async,
            "generator": is_generator
        }
    
    def function_expression(self, *args):
        # Similar to function_declaration
        async_idx = 0
        is_async = False
        if args and isinstance(args[0], Token) and args[0].type == "ASYNC":
            is_async = True
            async_idx = 1
        
        # Check for generator (*)
        current_idx = async_idx + 1  # Skip "function" keyword
        is_generator = False
        if current_idx < len(args) and str(args[current_idx]) == "*":
            is_generator = True
            current_idx += 1
        
        # Next might be the identifier (name) - optional for function expressions
        name = None
        if current_idx < len(args) and isinstance(args[current_idx], dict) and args[current_idx].get("type") == "Identifier":
            name = args[current_idx]
            current_idx += 1
        
        # Find params and body
        params = {"type": "Parameters", "params": []}
        body = args[-1]
        
        for i in range(current_idx, len(args)):
            if isinstance(args[i], dict) and args[i].get("type") == "Parameters":
                params = args[i]
                break
        
        return {
            "type": "FunctionExpression",
            "id": name,
            "params": params["params"],
            "body": body,
            "async": is_async,
            "generator": is_generator
        }
    
    def formal_parameter_list(self, *args):
        params = []
        for arg in args:
            if isinstance(arg, dict):
                params.append(arg)
        return {"type": "Parameters", "params": params}
    
    def formal_parameter_arg(self, assignable, *default):
        return {
            "type": "Parameter",
            "name": assignable,
            "default": default[0] if default else None
        }
    
    def last_formal_parameter_arg(self, expr):
        return {"type": "RestParameter", "argument": expr}
    
    def function_body(self, *elements):
        return {
            "type": "BlockStatement",
            "body": elements[0]["elements"] if elements and isinstance(elements[0], dict) else []
        }
    
    # Arrow functions
    def arrow_function(self, *args):
        is_async = False
        offset = 0
        if args and isinstance(args[0], Token) and args[0].type == "ASYNC":
            is_async = True
            offset = 1
        params = args[offset]
        body = args[offset + 1]
        
        return {
            "type": "ArrowFunctionExpression",
            "params": params["params"] if isinstance(params, dict) and "params" in params else [params],
            "body": body,
            "async": is_async
        }
    
    def arrow_function_parameters(self, *args):
        if len(args) == 1 and not isinstance(args[0], dict):
            return {"type": "Parameters", "params": [args[0]]}
        return args[0] if args else {"type": "Parameters", "params": []}
    
    def arrow_function_body(self, body):
        return body
    
    # Classes
    def class_declaration(self, name, tail):
        return {
            "type": "ClassDeclaration",
            "id": name,
            "superClass": tail.get("superClass") if isinstance(tail, dict) else None,
            "body": tail.get("body") if isinstance(tail, dict) else None
        }
    
    def class_expression(self, *args):
        name = args[0] if len(args) > 1 else None
        tail = args[-1]
        return {
            "type": "ClassExpression",
            "id": name,
            "superClass": tail.get("superClass"),
            "body": tail.get("body")
        }
    
    @v_args(inline=False)
    def class_tail(self, args):
        superclass = None
        body_elements = []
        
        # When there's an extends clause, args = [superclass_expr, method1, method2, ...]
        # When there's no extends, args = [method1, method2, ...]
        # The optional group ("extends" single_expression)? either produces the expression or nothing
        
        for arg in args:
            if isinstance(arg, list):
                # This is the list of class elements
                body_elements.extend(arg)
            elif isinstance(arg, dict):
                # Check if it's a class element or superclass
                if arg.get("type") == "MethodDefinition":
                    body_elements.append(arg)
                else:
                    # This should be the superclass expression
                    superclass = arg
        
        # Filter out None values
        body_elements = [e for e in body_elements if e is not None]
        
        return {
            "superClass": superclass,
            "body": {"type": "ClassBody", "body": body_elements}
        }
    
    def class_element(self, *args):
        # Return the method/property definition, filtering out modifiers
        for arg in args:
            if isinstance(arg, dict):
                return arg
        return None
    
    def method_definition(self, *args):
        return {"type": "MethodDefinition", "value": list(args)}
    
    # Control flow statements
    def empty_statement(self):
        return {"type": "EmptyStatement"}
    
    def expression_statement(self, expr, _eos):
        return {"type": "ExpressionStatement", "expression": expr}
    
    def if_statement(self, condition, then_stmt, *else_stmt):
        return {
            "type": "IfStatement",
            "test": condition,
            "consequent": then_stmt,
            "alternate": else_stmt[0] if else_stmt else None
        }
    
    def do_statement(self, body, condition, _eos):
        return {"type": "DoWhileStatement", "body": body, "test": condition}
    
    def while_statement(self, condition, body):
        return {"type": "WhileStatement", "test": condition, "body": body}
    
    def for_statement(self, *args):
        # Filter out eos
        args = [a for a in args if a is not None and not isinstance(a, Token)]
        
        return {
            "type": "ForStatement",
            "init": args[0] if len(args) > 3 else None,
            "test": args[1] if len(args) > 3 else (args[0] if len(args) > 2 else None),
            "update": args[2] if len(args) > 3 else (args[1] if len(args) > 2 else None),
            "body": args[-1]
        }
    
    def for_in_statement(self, left, right, body):
        return {"type": "ForInStatement", "left": left, "right": right, "body": body}
    
    def for_of_statement(self, *args):
        # Filter await if present
        is_await = "await" in [str(a) for a in args if not isinstance(a, dict)]
        left = args[0] if isinstance(args[0], dict) else args[1]
        right_idx = 1 if not is_await else 2
        right = args[right_idx] if len(args) > right_idx and isinstance(args[right_idx], dict) else args[right_idx + 1]
        body = args[-1]
        
        return {
            "type": "ForOfStatement",
            "left": left,
            "right": right,
            "body": body,
            "await": is_await
        }
    
    def continue_statement(self, *args):
        label = args[0] if args and isinstance(args[0], dict) else None
        return {"type": "ContinueStatement", "label": label}
    
    def break_statement(self, *args):
        label = args[0] if args and isinstance(args[0], dict) else None
        return {"type": "BreakStatement", "label": label}
    
    def return_statement(self, *args):
        argument = args[0] if args and isinstance(args[0], dict) else None
        return {"type": "ReturnStatement", "argument": argument}
    
    def with_statement(self, expr, stmt):
        return {"type": "WithStatement", "object": expr, "body": stmt}
    
    def switch_statement(self, discriminant, cases):
        return {"type": "SwitchStatement", "discriminant": discriminant, "cases": cases["cases"]}
    
    def case_block(self, *args):
        cases = []
        for arg in args:
            if isinstance(arg, list):
                # This is case_clauses - a list of cases
                cases.extend(arg)
            elif isinstance(arg, dict) and arg.get("type") == "SwitchCase":
                # This is a single case (like default_clause)
                cases.append(arg)
        return {"type": "CaseBlock", "cases": cases}
    
    def case_clauses(self, *clauses):
        return list(clauses)
    
    def case_clause(self, test, *consequent):
        # consequent might be a single list from statement_list
        if len(consequent) == 1 and isinstance(consequent[0], list):
            return {
                "type": "SwitchCase",
                "test": test,
                "consequent": consequent[0]
            }
        return {
            "type": "SwitchCase",
            "test": test,
            "consequent": list(consequent) if consequent else []
        }
    
    def default_clause(self, *consequent):
        # consequent might be a single list from statement_list
        if len(consequent) == 1 and isinstance(consequent[0], list):
            return {
                "type": "SwitchCase",
                "test": None,
                "consequent": consequent[0]
            }
        return {
            "type": "SwitchCase",
            "test": None,
            "consequent": list(consequent) if consequent else []
        }
    
    def labelled_statement(self, label, stmt):
        return {"type": "LabeledStatement", "label": label, "body": stmt}
    
    def throw_statement(self, argument, _eos):
        return {"type": "ThrowStatement", "argument": argument}
    
    def try_statement(self, block, *args):
        handler = None
        finalizer = None
        for arg in args:
            if arg and arg.get("type") == "CatchClause":
                handler = arg
            elif arg and arg.get("type") == "BlockStatement":
                finalizer = arg
        
        return {
            "type": "TryStatement",
            "block": block,
            "handler": handler,
            "finalizer": finalizer
        }
    
    def catch_production(self, *args):
        param = None
        body = args[-1]
        if len(args) > 1 and isinstance(args[0], dict):
            param = args[0]
        
        return {"type": "CatchClause", "param": param, "body": body}
    
    def finally_production(self, block):
        return block
    
    def debugger_statement(self, _eos):
        return {"type": "DebuggerStatement"}
    
    # Expressions
    def expression_sequence(self, *expressions):
        if len(expressions) == 1:
            return expressions[0]
        return {"type": "SequenceExpression", "expressions": list(expressions)}
    
    def assignment_expression(self, *args):
        if len(args) == 1:
            return args[0]
        # Arrow function or assignment
        if isinstance(args[0], dict) and args[0].get("type") == "ArrowFunctionExpression":
            return args[0]
        # Regular assignment: expr op expr
        return {
            "type": "AssignmentExpression",
            "operator": str(args[1]),
            "left": args[0],
            "right": args[2]
        }
    
    def assignment_operator(self, *args):
        # Handle assignment operators (=, +=, -=, etc.)
        return str(args[0]) if args else "="
    
    # Binary operations
    def _create_binary(self, *args):
        if len(args) == 1:
            return args[0]
        
        # args are: left, op1, right1, op2, right2, ...
        left = args[0]
        i = 1
        while i + 1 < len(args):  # Ensure we have both operator and operand
            left = {
                "type": "BinaryExpression",
                "operator": str(args[i]),
                "left": left,
                "right": args[i + 1]
            }
            i += 2
        return left
    
    def conditional_expression(self, *args):
        if len(args) == 3:
            return {"type": "ConditionalExpression", "test": args[0], "consequent": args[1], "alternate": args[2]}
        return args[0]
    
    @v_args(tree=True)
    def logical_or_expression(self, tree):
        return self._transform_binary(tree)
    
    def logical_or_op(self):
        return "||"
    
    @v_args(tree=True)
    def logical_and_expression(self, tree):
        return self._transform_binary(tree)
    
    def logical_and_op(self):
        return "&&"
    
    @v_args(tree=True)
    def bitwise_or_expression(self, tree):
        return self._transform_binary(tree)
    
    def bitwise_or_op(self):
        return "|"
    
    @v_args(tree=True)
    def bitwise_xor_expression(self, tree):
        return self._transform_binary(tree)
    
    def bitwise_xor_op(self):
        return "^"
    
    @v_args(tree=True)
    def bitwise_and_expression(self, tree):
        return self._transform_binary(tree)
    
    def bitwise_and_op(self):
        return "&"
    
    @v_args(tree=True)
    def equality_expression(self, tree):
        return self._transform_binary(tree)
    
    def eq_strict_eq(self):
        return "==="
    
    def eq_strict_neq(self):
        return "!=="
    
    def eq_eq(self):
        return "=="
    
    def eq_neq(self):
        return "!="
    
    @v_args(tree=True)
    def relational_expression(self, tree):
        return self._transform_binary(tree)
    
    def rel_lte(self):
        return "<="
    
    def rel_gte(self):
        return ">="
    
    def rel_lt(self):
        return "<"
    
    def rel_gt(self):
        return ">"
    
    def rel_instanceof(self):
        return "instanceof"
    
    def rel_in(self):
        return "in"
    
    @v_args(tree=True)
    def shift_expression(self, tree):
        return self._transform_binary(tree)
    
    def shift_left(self):
        return "<<"
    
    def shift_right(self):
        return ">>"
    
    def shift_right_unsigned(self):
        return ">>>"
    
    @v_args(tree=True)
    def additive_expression(self, tree):
        return self._transform_binary(tree)
    
    def add_plus(self):
        return "+"
    
    def add_minus(self):
        return "-"
    
    def _transform_binary(self, tree):
        """Helper to transform binary expressions with operators"""
        children = tree.children
        
        if len(children) == 1:
            return children[0]
        
        # Build binary expression: child0 op child1 op child2...
        left = children[0]
        i = 1
        while i + 1 < len(children):
            operator = children[i]  # The operator string
            right = children[i + 1]
            left = {
                "type": "BinaryExpression",
                "operator": operator,
                "left": left,
                "right": right
            }
            i += 2
        return left
    
    @v_args(tree=True)  
    def multiplicative_expression(self, tree):
        return self._transform_binary(tree)
    
    def mult_star(self):
        return "*"
    
    def mult_slash(self):
        return "/"
    
    def mult_percent(self):
        return "%"
    
    def exponentiation_expression(self, base, *exp):
        if exp:
            return {"type": "BinaryExpression", "operator": "**", "left": base, "right": exp[0]}
        return base
    
    def unary_expression(self, *args):
        if len(args) == 2:
            return {"type": "UnaryExpression", "operator": str(args[0]), "argument": args[1]}
        return args[0]
    
    def yield_expression(self, *args):
        # args could be: () for plain yield, or (expr) for yield value, or ("*", expr) for yield*
        if not args:
            return {"type": "YieldExpression", "argument": None, "delegate": False}
        elif len(args) == 1:
            return {"type": "YieldExpression", "argument": args[0], "delegate": False}
        else:
            # yield* expression
            return {"type": "YieldExpression", "argument": args[1], "delegate": True}
    
    @v_args(tree=True)
    def postfix_expression(self, tree):
        # tree.children: [expr] or [expr, op_string]
        if len(tree.children) > 1:
            expr = tree.children[0]
            op = str(tree.children[1])  # This is now the result from postfix_increment/decrement
            return {"type": "UpdateExpression", "operator": op, "argument": expr, "prefix": False}
        return tree.children[0]
    
    def postfix_increment(self):
        return "++"
    
    def postfix_decrement(self):
        return "--"
    
    def primary_expression(self, *args):
        # Pass through - this handles the case where Earley doesn't unwrap the ? rule
        # For "this", it might be called with no args (token directly)
        if not args:
            return {"type": "ThisExpression"}
        return args[0]
    
    def member_expression(self, *args):
        if len(args) == 1:
            return args[0]
        
        obj = args[0]
        for i in range(1, len(args)):
            arg = args[i]
            if isinstance(arg, dict):
                if arg.get("type") == "Arguments":
                    obj = {"type": "CallExpression", "callee": obj, "arguments": arg["arguments"]}
                else:
                    # Member access
                    obj = {
                        "type": "MemberExpression",
                        "object": obj,
                        "property": arg,
                        "computed": False
                    }
        return obj
    
    def arguments(self, *args):
        return {"type": "Arguments", "arguments": list(args)}
    
    def member_expr_computed(self, obj, expr):
        return {"type": "MemberExpression", "object": obj, "property": expr, "computed": True}
    
    def member_expr_property(self, obj, prop):
        return {"type": "MemberExpression", "object": obj, "property": prop, "computed": False}
    
    def member_expr_call(self, obj, args):
        return {"type": "CallExpression", "callee": obj, "arguments": args["arguments"] if isinstance(args, dict) else []}
    
    def member_expr_new(self, expr, args):
        return {"type": "NewExpression", "callee": expr, "arguments": args["arguments"] if isinstance(args, dict) else []}
    
    def member_expr_super(self):
        return {"type": "Super"}
    
    # Literals
    def null_literal(self):
        return {"type": "Literal", "value": None}
    
    def boolean_literal(self, value):
        return {"type": "Literal", "value": str(value) == "true"}
    
    def numeric_literal(self, value):
        val_str = str(value)
        if val_str.startswith("0x") or val_str.startswith("0X"):
            return {"type": "Literal", "value": int(val_str, 16)}
        elif val_str.startswith("0o") or val_str.startswith("0O"):
            return {"type": "Literal", "value": int(val_str, 8)}
        elif val_str.startswith("0b") or val_str.startswith("0B"):
            return {"type": "Literal", "value": int(val_str, 2)}
        elif "." in val_str or "e" in val_str or "E" in val_str:
            return {"type": "Literal", "value": float(val_str)}
        else:
            return {"type": "Literal", "value": int(val_str)}
    
    def string_literal(self, value):
        return {"type": "Literal", "value": str(value)[1:-1]}
    
    def regex_literal(self, value):
        return {"type": "Literal", "value": str(value), "regex": True}
    
    def template_string_literal(self, *args):
        return {"type": "TemplateLiteral", "parts": list(args)}
    
    @v_args(tree=True)
    def template_string_atom(self, tree):
        # Check if it's a TEMPLATE_STRING_ATOM token or an expression
        if len(tree.children) == 1 and isinstance(tree.children[0], Token):
            # Just a template string token
            return {"type": "TemplateElement", "value": str(tree.children[0])}
        elif tree.children:
            # Expression interpolation: ${expr}
            return {"type": "TemplateExpression", "expression": tree.children[0]}
        return {"type": "TemplateElement", "value": ""}
    
    def array_literal(self, *elements):
        # element_list returns a list, so we need to flatten it
        if len(elements) == 1 and isinstance(elements[0], list):
            return {"type": "ArrayExpression", "elements": elements[0]}
        return {"type": "ArrayExpression", "elements": list(elements) if elements else []}
    
    def element_list(self, *elements):
        # Filter out None values (from elisions represented by empty commas)
        return [e for e in elements if e is not None]
    
    def spread_element(self, expr):
        return {"type": "SpreadElement", "argument": expr}
    
    def array_element_expr(self, expr):
        return expr
    
    def object_literal(self, *properties):
        return {"type": "ObjectExpression", "properties": list(properties)}
    
    def property_expression_assignment(self, key, value):
        return {"type": "Property", "key": key, "value": value, "kind": "init"}
    
    def computed_property_expression_assignment(self, key, value):
        return {"type": "Property", "key": key, "value": value, "computed": True, "kind": "init"}
    
    def property_getter_setter(self, *args):
        # Now the first arg should be the GET/SET token
        kind = str(args[0]).lower()  # Convert GET/SET token to lowercase string
        key = args[1]                # property_name  
        params = None
        body = args[-1]              # function_body (always last)
        
        # Look for parameters between key and body
        for i in range(2, len(args) - 1):
            if isinstance(args[i], dict) and args[i].get("type") == "Parameters":
                params = args[i]
                break
        
        return {
            "type": "Property",
            "key": key,
            "value": {
                "type": "FunctionExpression",
                "params": params["params"] if params else [],
                "body": body
            },
            "kind": kind
        }
    
    def method_property(self, *args):
        # Handle async and generator flags
        is_async = False
        is_generator = False
        offset = 0
        
        # Check for async keyword first
        if args and isinstance(args[0], Token) and args[0].type == "ASYNC":
            is_async = True
            offset += 1
        
        # Check for generator (*) after async
        if offset < len(args) and str(args[offset]) == "*":
            is_generator = True
            offset += 1
        
        # Next should be the property name
        key = args[offset] if offset < len(args) else None
        
        # Find params and body
        params = None
        body = args[-1]
        for arg in args:
            if isinstance(arg, dict) and arg.get("type") == "Parameters":
                params = arg
                break
        
        return {
            "type": "Property",
            "key": key,
            "value": {
                "type": "FunctionExpression",
                "params": params["params"] if params else [],
                "body": body,
                "async": is_async,
                "generator": is_generator
            },
            "method": True,
            "kind": "init"
        }
    
    def property_shorthand(self, identifier):
        return {
            "type": "Property",
            "key": identifier,
            "value": identifier,
            "shorthand": True,
            "kind": "init"
        }
    
    def rest_parameter(self, expr):
        return {"type": "RestElement", "argument": expr}
    
    def property_name(self, name):
        return name
    
    # Import/Export
    def import_statement(self, block):
        return {"type": "ImportDeclaration", "specifiers": block.get("specifiers", []), "source": block.get("source")}
    
    def import_from_block(self, *args):
        specifiers = []
        source = None
        for arg in args:
            if isinstance(arg, dict):
                if arg.get("type") == "ImportSpecifier":
                    specifiers.append(arg)
                elif arg.get("type") == "Literal":
                    source = arg
        return {"type": "ImportFromBlock", "specifiers": specifiers, "source": source}
    
    def import_module_items(self, *items):
        return {"type": "ImportModuleItems", "items": list(items)}
    
    def import_alias_name(self, *args):
        return {"type": "ImportSpecifier", "imported": args[0], "local": args[1] if len(args) > 1 else args[0]}
    
    def export_declaration(self, *args):
        is_default = "default" in [str(a) for a in args if not isinstance(a, dict)]
        declaration = args[-1]
        
        return {
            "type": "ExportNamedDeclaration" if not is_default else "ExportDefaultDeclaration",
            "declaration": declaration
        }
    
    def export_default_declaration(self, expr, _eos):
        return {"type": "ExportDefaultDeclaration", "declaration": expr}
    
    # Identifiers
    def identifier(self, name):
        return {"type": "Identifier", "name": str(name)}
    
    def contextual_keyword(self, *args):
        # Handle contextual keywords (async, await, yield, let, as, of, get, set, static)
        # args[0] is a Token object for the keyword
        keyword = str(args[0]) if args else "unknown"
        return {"type": "Identifier", "name": keyword}
    
    def eos(self, *args):
        return args[0] if args else None


# Create parser with Earley algorithm (handles ambiguity) with priority resolution
parser = Lark(javascript_grammar, parser='earley', priority='normal')


def parse_javascript(code):
    """Parse JavaScript code and return AST"""
    tree = parser.parse(code)
    transformer = JSTransformer()
    ast = transformer.transform(tree)
    return ast
    


# Example usage
if __name__ == "__main__":
    import sys
    if len(sys.argv) > 1:
        # Parse a specific file
        with open(sys.argv[1], 'r') as f:
            code = f.read()
        ast = parse_javascript(code)
        print(json.dumps(ast, indent=2))
    else:
        print("Usage: python parser.py <javascript_file>")