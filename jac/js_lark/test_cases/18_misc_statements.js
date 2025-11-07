// Test 18: Miscellaneous statements
debugger;

// Labeled statements
loop1: for (let i = 0; i < 5; i++) {
    loop2: for (let j = 0; j < 5; j++) {
        if (i === 2 && j === 2) {
            break loop1;
        }
    }
}

// With statement
with (obj) {
    console.log(property);
}

// Throw statement
throw new Error("Something went wrong");
throw "Error string";

// Return statements
function test() {
    return;
    return value;
    return a + b;
}

// Empty statements
;;
if (true) ;
