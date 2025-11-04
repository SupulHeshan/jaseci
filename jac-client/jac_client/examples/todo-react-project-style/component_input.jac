cl def Input(props: dict) -> any {
    value = props.get("value");
    onChange = props.get("onChange", lambda e: any -> None {});
    placeholder = props.get("placeholder", "");
    type = props.get("type", "text");
    id = props.get("id");

    return <input
        id={id}
        type={type}
        value={value}
        onChange={onChange}
        placeholder={placeholder}
        style={{
            "width": "100%",
            "padding": "10px",
            "border": "1px solid #ddd",
            "borderRadius": "4px",
            "fontSize": "16px",
            "boxSizing": "border-box"
        }}
    />;
}
