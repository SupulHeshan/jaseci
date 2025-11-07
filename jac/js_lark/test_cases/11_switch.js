// Test 11: Switch statements
switch (value) {
    case 1:
        console.log("one");
        break;
    case 2:
        console.log("two");
        break;
    case 3:
    case 4:
        console.log("three or four");
        break;
    default:
        console.log("other");
}

// Switch without break (fall-through)
switch (x) {
    case "a":
        doA();
    case "b":
        doB();
    default:
        doDefault();
}
