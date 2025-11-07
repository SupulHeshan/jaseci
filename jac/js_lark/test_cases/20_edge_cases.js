// Test 20: Edge cases and special scenarios
const emptyFunc = function() {};
const emptyArrow = () => {};
const emptyObj = {};
const emptyArray = [];

// Single line
const oneLine = () => single;

// Comments
// Single line comment
/* Multi-line
   comment */

// Semicolon insertion
const a = 1
const b = 2
const c = 3

// Generator with yield
function* gen() {
    yield 1;
    yield* other();
}

// Contextual keywords as identifiers
const async = 1;
const await = 2;
const let = 3;
const of = 4;
