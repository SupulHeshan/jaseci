cl import from .component_input { Input }
cl import from .component_button { Button }

cl def TodoForm(props: dict) -> any {
    onSubmit = props.get("onSubmit", lambda text: str -> None {});
    let [inputValue, setInputValue] = createState("");
    
    def handleSubmit(e: any) -> None {
        e.preventDefault();
        text = inputValue().trim();
        if text {
            onSubmit(text);
            setInputValue("");
        }
    }
    
    return <form onSubmit={handleSubmit} style={{"display": "flex", "gap": "8px", "marginBottom": "20px"}}>
        <Input
            value={inputValue()}
            onChange={lambda e: any -> None { setInputValue(e.target.value); }}
            placeholder="What needs to be done?"
            id="todo-input"
        />
        <Button label="Add Todo" type="submit" />
    </form>;
}
