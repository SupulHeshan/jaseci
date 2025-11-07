// Test 12: Try-catch-finally
try {
    riskyOperation();
} catch (error) {
    console.error(error);
}

// With finally
try {
    doSomething();
} catch (e) {
    handleError(e);
} finally {
    cleanup();
}

// Try-finally without catch
try {
    doSomething();
} finally {
    cleanup();
}

// Nested try-catch
try {
    try {
        innerOperation();
    } catch (inner) {
        handleInner(inner);
    }
} catch (outer) {
    handleOuter(outer);
}

// Catch without parameter
try {
    doSomething();
} catch {
    console.log("Error occurred");
}
