// Test 7: Destructuring
const [a, b, c] = [1, 2, 3];
const [first, ...rest] = [1, 2, 3, 4, 5];

// Object destructuring
const { x, y } = { x: 10, y: 20 };
const { name, age } = person;

// Nested destructuring
const [p, [q, r]] = [1, [2, 3]];
const { outer: { inner } } = { outer: { inner: 42 } };
