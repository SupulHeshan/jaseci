// Test 4: Classes
class Person {
    constructor(name, age) {
        this.name = name;
        this.age = age;
    }
    
    greet() {
        return "Hello, " + this.name;
    }
    
    static create(name) {
        return new Person(name, 0);
    }
}

// Class with inheritance
class Employee extends Person {
    constructor(name, age, salary) {
        super(name, age);
        this.salary = salary;
    }
    
    getSalary() {
        return this.salary;
    }
}

// Class expression
const Animal = class {
    constructor(type) {
        this.type = type;
    }
};
