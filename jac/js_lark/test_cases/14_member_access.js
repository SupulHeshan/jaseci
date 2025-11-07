// Test 14: Member expressions
const prop = obj.property;
const nested = obj.nested.deep.value;
const computed = obj["property"];
const dynamic = obj[key];

// Method calls
const result = obj.method();
const chained = obj.method1().method2().method3();

// Array access
const first = arr[0];
const last = arr[arr.length - 1];

// New expressions
const instance = new Constructor();
const withArgs = new MyClass(arg1, arg2);
const nested = new obj.Constructor();

// Super
class Child extends Parent {
    constructor() {
        super();
    }
}

// This
function context() {
    return this.value;
}
