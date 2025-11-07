// Test 19: Complex nested expressions
const complex = (a + b) * (c - d) / (e % f);
const precedence = a + b * c - d / e;
const grouped = ((a + b) * c) ** 2;

// Sequence expressions
const seq = (expr1, expr2, expr3);
let x = (y = 5, z = 10, y + z);

// Conditional chains
const result = a ? b : c ? d : e;
const nested = x > 0 ? (y > 0 ? "both" : "x only") : "neither";

// Mixed operations
const mixed = arr.map(x => x * 2).filter(x => x > 10).reduce((a, b) => a + b, 0);

// Complex member access
const deep = obj?.property?.method()?.result;
const computed = obj[key1][key2][key3];
