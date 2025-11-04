cl def Card(props: dict) -> any {
    children = props.get("children");
    title = props.get("title");
    
    return <div style={{
        "maxWidth": "600px",
        "margin": "0 auto",
        "padding": "24px",
        "background": "white",
        "borderRadius": "12px",
        "boxShadow": "0 1px 3px rgba(0,0,0,0.1)",
        "fontFamily": "system-ui, -apple-system, sans-serif"
    }}>
        {title ? <h2 style={{"marginTop": "0", "marginBottom": "20px", "color": "#111827"}}>{title}</h2> : None}
        {children}
    </div>;
}
