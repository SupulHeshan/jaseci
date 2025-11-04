cl import from .component_todoItem { TodoItem }

cl def TodoList(props: dict) -> any {
    items = props.get("items", []);
    onToggle = props.get("onToggle", lambda id: any -> None {});
    onDelete = props.get("onDelete", lambda id: any -> None {});
    
    if len(items) == 0 {
        return <div style={{"textAlign": "center", "padding": "40px", "color": "#9ca3af"}}>
            <p>No todos yet. Add one above!</p>
        </div>;
    }
    
    children = [];
    for item in items {
        children.push(TodoItem({"item": item, "onToggle": lambda -> None { onToggle(item.id); }, "onDelete": lambda -> None { onDelete(item.id); }}));
    }
    return <ul style={{"listStyle": "none", "padding": "0", "margin": "0"}}>{children}</ul>;
}
