// Test 8: All operators
const arithmetic = a + b - c * d / e % f;
const exponent = base ** power;

// Comparison
const eq = a === b;
const neq = a !== b;
const loose = a == b;
const lt = a < b;
const gt = a > b;
const lte = a <= b;
const gte = a >= b;

// Logical
const and = a && b;
const or = a || b;
const not = !a;

// Bitwise
const bitAnd = a & b;
const bitOr = a | b;
const bitXor = a ^ b;
const bitNot = ~a;
const leftShift = a << b;
const rightShift = a >> b;
const unsignedRight = a >>> b;

// Assignment
let x = 10;
x += 5;
x -= 3;
x *= 2;
x /= 4;
x %= 3;
x **= 2;
x <<= 1;
x >>= 1;
x >>>= 1;
x &= 0xFF;
x |= 0x01;
x ^= 0x10;

// Unary
const inc = ++x;
const dec = --y;
const postInc = x++;
const postDec = y--;
const typeOf = typeof x;
const deleted = delete obj.prop;
const voided = void 0;

// Ternary
const result = condition ? trueVal : falseVal;
