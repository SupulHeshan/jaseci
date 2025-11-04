cl import from .component_button { Button }

cl def TodoItem(props: dict) -> any {
    item = props.get("item");
    onToggle = props.get("onToggle", lambda -> None {});
    onDelete = props.get("onDelete", lambda -> None {});
    
    return <li style={{
        "display": "flex",
        "gap": "12px",
        "alignItems": "center",
        "padding": "12px",
        "marginBottom": "8px",
        "background": "#f9fafb",
        "borderRadius": "6px",
        "border": "1px solid #e5e7eb"
    }}>
        <input
            type="checkbox"
            checked={item.done}
            onChange={onToggle}
            style={{"cursor": "pointer", "width": "18px", "height": "18px"}}
        />
        <span style={{
            "flex": "1",
            "textDecoration": item.done ? "line-through" : "none",
            "color": item.done ? "#9ca3af" : "#111827",
            "fontSize": "16px"
        }}>
            {item.text}
        </span>
        <Button label="Delete" variant="danger" onClick={onDelete} />
    </li>;
}
