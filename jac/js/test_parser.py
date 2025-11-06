from antlr4 import *
from gen.JavaScriptLexer import JavaScriptLexer
from gen.JavaScriptParser import JavaScriptParser
from gen.JavaScriptParserListener import JavaScriptParserListener
import json


def node_to_dict(node):
    """Convert an ESTree node to a dictionary for JSON serialization."""
    if hasattr(node, "__dict__"):
        result = {"type": node.type}
        for key, value in node.__dict__.items():
            if key != "type" and key != "loc" and value is not None:
                if isinstance(value, list):
                    result[key] = [
                        node_to_dict(item) for item in value if item is not None
                    ]
                else:
                    result[key] = node_to_dict(value)
        return result
    return node


def parse_javascript(code: str):
    """Parse JavaScript code and return ESTree AST."""
    # Create the input stream
    input_stream = InputStream(code)

    # Create lexer and token stream
    lexer = JavaScriptLexer(input_stream)
    stream = CommonTokenStream(lexer)

    # Create parser
    parser = JavaScriptParser(stream)

    # Create parse tree
    tree = parser.program()

    # Create and setup listener
    listener = JavaScriptParserListener()

    # Walk the parse tree with our listener
    walker = ParseTreeWalker()
    walker.walk(listener, tree)

    # Return the AST
    return listener.ast


def main():
    # Test code that exercises different node types
    f = open("test.js", "r")
    test_code = f.read()
    f.close()

    # Parse the code
    ast = parse_javascript(test_code)

    # # Convert to dictionary and print as JSON
    # ast_dict = node_to_dict(ast)
    # print(json.dumps(ast_dict, indent=2))


if __name__ == "__main__":
    main()
