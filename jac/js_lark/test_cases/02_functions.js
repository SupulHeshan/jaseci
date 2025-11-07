// Test 2: Function declarations and expressions
function add(a, b) {
    return a + b;
}

// Function expression
const multiply = function(x, y) {
    return x * y;
};

// Named function expression
const factorial = function fact(n) {
    if (n <= 1) return 1;
    return n * fact(n - 1);
};

// Generator function
function* generator() {
    yield 1;
    yield 2;
}

// Async function
async function fetchData() {
    return await Promise.resolve("data");
}
