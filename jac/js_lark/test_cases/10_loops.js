// Test 10: Loop statements
for (let i = 0; i < 10; i++) {
    console.log(i);
}

// For without init
for (; i < 20; i++) {
    console.log(i);
}

// For-in
for (let key in obj) {
    console.log(key);
}

// For-of
for (let value of array) {
    console.log(value);
}

// For-await-of
for await (let item of asyncIterable) {
    console.log(item);
}

// While
while (condition) {
    doSomething();
}

// Do-while
do {
    doSomething();
} while (condition);

// Loop control
for (let i = 0; i < 100; i++) {
    if (i === 10) break;
    if (i % 2 === 0) continue;
    console.log(i);
}
