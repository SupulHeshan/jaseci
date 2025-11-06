# Generating JavaScript Parser with ANTLR4

## Prerequisites

1. Verify ANTLR4 is installed and available:
```bash
antlr4
```

If not installed, follow these steps:
```bash
# Install Java (if needed)
sudo apt update
sudo apt install openjdk-17-jdk

# Download and setup ANTLR4
cd /usr/local/lib
sudo curl -O https://www.antlr.org/download/antlr-4.13.1-complete.jar

# Add to ~/.bashrc
export CLASSPATH=".:/usr/local/lib/antlr-4.13.1-complete.jar:$CLASSPATH"
alias antlr4='java -jar /usr/local/lib/antlr-4.13.1-complete.jar'
alias grun='java org.antlr.v4.gui.TestRig'

# Reload bash profile
source ~/.bashrc
```

## Getting the JavaScript Grammar

1. Create a directory for the grammar:
```bash
mkdir -p grammar
cd grammar
```

2. Clone the JavaScript grammar from the ANTLR4 grammar repository:
```bash
git clone --depth 1 https://github.com/antlr/grammars-v4.git
cp -r grammars-v4/javascript/javascript/Python3 .
cp -r grammars-v4/javascript/javascript/*g4 .
rm -rf Cpp CSharp Java JavaScript examples Go _scripts
rm -rf grammars-v4
```

## Generate the Parser

1. Generate the Python target code:
```bash
# Install the ANTLR4 Python runtime
pip install antlr4-python3-runtime

# Generate both Lexer and Parser
python Python3/transformGrammar.py
antlr4 -Dlanguage=Python3 JavaScript*.g4 -o gen
cp Python3/JavaScript*py gen/
```

This will generate several Python files:
- `JavaScriptLexer.py`
- `JavaScriptParser.py`
- `JavaScriptParserListener.py`

## Testing the Parser

1. Create a simple test script (test_parser.py):
```python
from antlr4 import *
from antlr4.atn.PredictionMode import PredictionMode
from JavaScriptLexer import JavaScriptLexer
from JavaScriptParser import JavaScriptParser

def parse(text):
    input_stream = InputStream(text)
    lexer = JavaScriptLexer(input_stream)
    stream = CommonTokenStream(lexer)
    parser = JavaScriptParser(stream)

    # Set the parser base
    parser._interp.predictionMode = PredictionMode.SLL

    # Parse the input
    tree = parser.program()
    return tree

# Test with simple JavaScript code
code = """
function hello(name) {
    return "Hello, " + name;
}
"""

tree = parse(code)
print(tree.toStringTree(recog=parser))
```

2. Run the test:
```bash
python3 test_parser.py
```

## Using the Generated Parser

The generated parser can be used in your Python code:

```python
from antlr4 import *
from JavaScriptLexer import JavaScriptLexer
from JavaScriptParser import JavaScriptParser
from JavaScriptParserVisitor import JavaScriptParserVisitor

class MyVisitor(JavaScriptParserVisitor):
    def visitFunctionDeclaration(self, ctx):
        name = ctx.identifier().getText()
        print(f"Found function: {name}")
        return self.visitChildren(ctx)

def parse_and_visit(code):
    input_stream = InputStream(code)
    lexer = JavaScriptLexer(input_stream)
    stream = CommonTokenStream(lexer)
    parser = JavaScriptParser(stream)
    tree = parser.program()

    visitor = MyVisitor()
    visitor.visit(tree)
```

## Common Issues and Solutions

1. If you get syntax errors in generated files:
   - Make sure you have the latest version of ANTLR4
   - Check that your Python version matches the target

2. If the parser fails to recognize valid JavaScript:
   - Update to the latest grammar files
   - Check for any required grammar customizations

3. Memory issues with large files:
   - Consider using the parser in streaming mode
   - Break down large files into smaller chunks

## Additional Resources

- [ANTLR4 Documentation](https://github.com/antlr/antlr4/blob/master/doc/index.md)
- [JavaScript Grammar Repository](https://github.com/antlr/grammars-v4/tree/master/javascript/javascript)
- [ANTLR4 Python Target](https://github.com/antlr/antlr4/blob/master/doc/python-target.md)
