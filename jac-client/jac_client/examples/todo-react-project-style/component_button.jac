cl def Button(props: dict) -> any {
    label = props.get("label", props.get("children", ""));
    onClick = props.get("onClick", lambda -> None {});
    variant = props.get("variant", "primary");
    disabled = props.get("disabled", False);
    type = props.get("type", "button");
    style = props.get("style", {});
    
    variantStyles = {
        "primary": {"background": "#7C3AED", "color": "white"},
        "danger": {"background": "#ef4444", "color": "white"},
        "secondary": {"background": "#6b7280", "color": "white"}
    };
    
    baseStyle = {
        "padding": "10px 20px",
        "border": "none",
        "borderRadius": "4px",
        "cursor": disabled ? "not-allowed" : "pointer",
        "opacity": disabled ? 0.6 : 1,
        "fontWeight": "500",
        "transition": "all 0.2s ease"
    };
    selectedVariant = variantStyles.get(variant, variantStyles["primary"]);
    mergedStyle = {};
    for key in baseStyle { mergedStyle[key] = baseStyle[key]; }
    for key in selectedVariant { mergedStyle[key] = selectedVariant[key]; }
    for key in style { mergedStyle[key] = style[key]; }
    
    return <button onClick={onClick} disabled={disabled} type={type} style={mergedStyle}>{label}</button>;
}
