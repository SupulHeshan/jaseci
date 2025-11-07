// Test 13: Async/await
async function getData() {
    const result = await fetch("/api");
    return result.json();
}

// Async arrow
const asyncArrow = async () => {
    const data = await loadData();
    return process(data);
};

// Async method
const obj = {
    async fetchUser() {
        return await api.getUser();
    }
};

// Multiple awaits
async function multiple() {
    const a = await promise1();
    const b = await promise2();
    return a + b;
}

// Await in loop
async function processItems(items) {
    for (const item of items) {
        await processItem(item);
    }
}
