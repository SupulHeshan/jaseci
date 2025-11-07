# JavaScript Parser - Test Suite

A comprehensive JavaScript parser built with LARK, supporting ES6+ features.

## Quick Start

```bash
# Run all tests with detailed output
python3 run_tests.py

# Quick pass/fail summary
./quick_test.sh

# Parse a specific file
python3 parser.py test_cases/03_arrow_functions.js
```

## Test Results

**✅ 15/20 tests passing (75% success rate)**

### Fully Supported Features

#### Variables & Functions
- ✅ Variable declarations (var, let, const)
- ✅ Function declarations and expressions  
- ✅ Arrow functions (all syntaxes)
- ✅ Async/await functions
- ✅ Function parameters with defaults
- ✅ Rest parameters

#### Objects & Classes
- ✅ Object literals with all features:
  - Property shorthand
  - Computed properties
  - Method shorthand
  - Getters/setters
  - Spread properties
- ✅ Classes with inheritance
- ✅ Constructor methods
- ✅ Static methods
- ✅ Class expressions

#### Arrays & Destructuring
- ✅ Array literals
- ✅ Array spread operator
- ✅ Array destructuring with rest
- ✅ Object destructuring
- ✅ Nested destructuring

#### Operators (All Types)
- ✅ Arithmetic: `+ - * / % **`
- ✅ Comparison: `=== !== == != < > <= >=`
- ✅ Logical: `&& || !`
- ✅ Bitwise: `& | ^ ~ << >> >>>`
- ✅ Assignment: `= += -= *= /= %= **= <<= >>= >>>= &= |= ^=`
- ✅ Unary: `++ -- typeof delete void`
- ✅ Ternary: `condition ? true : false`
- ✅ **Binary expressions in arrow functions: `x => x * 2`** ⭐

#### Control Flow
- ✅ If-else statements
- ✅ For loops (init, test, update)
- ✅ For-in and for-of loops
- ✅ For-await-of loops
- ✅ While and do-while loops
- ✅ Switch statements with default
- ✅ Break and continue
- ✅ Labeled statements

#### Error Handling
- ✅ Try-catch-finally
- ✅ Throw statements
- ✅ Catch without parameter

#### Modern ES6+ Features
- ✅ Template literals with interpolation
- ✅ Import/export statements
- ✅ Spread operator
- ✅ Rest parameters
- ✅ Destructuring
- ✅ Arrow functions
- ✅ Class inheritance
- ✅ Async/await

#### Literals
- ✅ Numbers: decimal, hex, octal, binary, scientific
- ✅ Strings: single, double quotes
- ✅ Template strings
- ✅ Regular expressions with flags
- ✅ Boolean, null

### Known Limitations

❌ Not yet supported:
1. Yield expressions in generators
2. Async method shorthand in objects (`async methodName() {}`)
3. Optional chaining operator (`?.`)

## Test Cases

| Test | File | Status | Description |
|------|------|--------|-------------|
| 01 | `01_variables.js` | ✅ | Variable declarations |
| 02 | `02_functions.js` | ❌ | Functions (fails on yield) |
| 03 | `03_arrow_functions.js` | ✅ | Arrow functions |
| 04 | `04_classes.js` | ✅ | Classes |
| 05 | `05_objects.js` | ❌ | Objects (fails on async shorthand) |
| 06 | `06_arrays.js` | ✅ | Arrays |
| 07 | `07_destructuring.js` | ✅ | Destructuring |
| 08 | `08_operators.js` | ✅ | All operators |
| 09 | `09_if_else.js` | ✅ | If-else |
| 10 | `10_loops.js` | ✅ | All loops |
| 11 | `11_switch.js` | ✅ | Switch statements |
| 12 | `12_try_catch.js` | ✅ | Error handling |
| 13 | `13_async_await.js` | ❌ | Async/await (fails on async shorthand) |
| 14 | `14_member_access.js` | ✅ | Member expressions |
| 15 | `15_template_literals.js` | ✅ | Template strings |
| 16 | `16_literals.js` | ✅ | All literals |
| 17 | `17_import_export.js` | ✅ | Modules |
| 18 | `18_misc_statements.js` | ✅ | Misc statements |
| 19 | `19_complex_expressions.js` | ❌ | Complex (fails on ?.) |
| 20 | `20_edge_cases.js` | ❌ | Edge cases (fails on yield) |

## Example Output

Arrow function with binary expression (`x => x * 2`):

```json
{
  "type": "ArrowFunctionExpression",
  "params": [
    {
      "type": "Identifier",
      "name": "x"
    }
  ],
  "body": {
    "type": "BinaryExpression",
    "operator": "*",
    "left": {
      "type": "Identifier",
      "name": "x"
    },
    "right": {
      "type": "Literal",
      "value": 2
    }
  },
  "async": false
}
```

## Architecture

The parser uses:
- **LARK** Earley parser with priority resolution
- **Explicit operator grammar rules** to preserve operators through transformation
- **@v_args decorators** for tree access when needed
- **Terminal priorities** to resolve keyword/identifier ambiguities

### Key Implementation Details

**Operator Preservation Pattern:**
```python
# Grammar
mult_op: "*" -> mult_star
       | "/" -> mult_slash

# Transformer
def mult_star(self): return "*"
def mult_slash(self): return "/"
```

This ensures operators aren't filtered out by LARK's token filtering.

## Files

- `parser.py` - Main parser implementation
- `run_tests.py` - Comprehensive test runner with detailed output
- `quick_test.sh` - Quick pass/fail summary
- `test_cases/` - 20 test files covering all features
- `TEST_RESULTS.md` - Detailed test results
- `test_output_sample.json` - Sample AST output

## Main Achievement

✅ **Arrow function binary expressions work perfectly!**

The original issue where `x => x * 2` only showed `x` instead of the full `BinaryExpression` is now completely resolved. All operators are preserved and binary expressions are properly structured in the AST.
