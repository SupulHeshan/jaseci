// Variable declarations
const greeting = "Hello";
let count = 42;
var flag = true;

// Function declaration
function add(a, b) {
    return a + b;
}

// Arrow function
const multiply = (x, y) => x * y;

// Class declaration
class Person {
    constructor(name) {
        this.name = name;
    }

    sayHello() {
        return `Hello, ${this.name}!`;
    }
}

// Object and array literals
const config = {
    debug: true,
    numbers: [1, 2, 3],
    settings: {
        theme: 'dark'
    }
};

// Control flow
if (count > 0) {
    for (let i = 0; i < count; i++) {
        console.log(i);
    }
}