// Test 3: Arrow functions
const simple = x => x * 2;
const withParens = (a, b) => a + b;
const withBlock = (n) => {
    const result = n * n;
    return result;
};

// Async arrow
const asyncArrow = async () => await fetch("/api");

// Complex expressions
const complex = x => x * 2 + 3 - 1;
const nested = a => b => a + b;
