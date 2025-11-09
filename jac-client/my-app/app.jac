
# Pages
cl import from react {useState, useEffect}
cl import from "@jac-client/utils" {log_test}
cl {
    def App() -> any {
        let [count, setCount] = useState(0);
        useEffect(lambda -> None {
            log_test();
        }, [count]);
        return <div>
            <h1>Hello, World!</h1>
            <p>Count: {count}</p>
            <button onClick={lambda e: any ->  None {setCount(count + 1);}}>Increment</button>
        </div>;
    }
}
