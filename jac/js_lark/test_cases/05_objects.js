// Test 5: Object literals
const obj = {
    name: "Test",
    value: 42,
    nested: {
        x: 1,
        y: 2
    }
};

// Method shorthand
const methods = {
    method() {
        return this.value;
    },
    async asyncMethod() {
        return await Promise.resolve(1);
    }
};

// Computed properties
const key = "dynamic";
const computed = {
    [key]: "value",
    ["prop" + "2"]: 100
};

// Getters and setters
const accessors = {
    get value() {
        return this._value;
    },
    set value(v) {
        this._value = v;
    }
};

// Property shorthand
const x = 10, y = 20;
const shorthand = { x, y };

// Spread properties
const spread = { ...obj, ...methods };
