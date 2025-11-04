cl import from .hook_useAuth { useAuth }
cl import from .component_card { Card }
cl import from .component_input { Input }
cl import from .component_button { Button }

cl def LoginPage() -> any {
    auth = useAuth();
    let [username, setUsername] = createState("");
    let [password, setPassword] = createState("");
    let [error, setError] = createState("");
    
    async def handleSubmit(e: any) -> None {
        e.preventDefault();
        result = await auth["login"](username(), password());
        if result["success"] {
            navigate("/todos");
        } else {
            setError(result["error"] if result["error"] else "Login failed");
        }
    }
    
    return <Card>
        <h2 style={{"textAlign": "center", "marginBottom": "24px"}}>Welcome Back</h2>
        {error() ? <div style={{"padding": "12px", "background": "#fee2e2", "color": "#dc2626", "borderRadius": "6px", "marginBottom": "16px"}}>{error()}</div> : None}
        <form onSubmit={handleSubmit}>
            <div style={{"marginBottom": "16px"}}>
                <label style={{"display": "block", "marginBottom": "8px", "fontWeight": "500"}}>Username</label>
                <Input
                    id="login-username"
                    value={username()}
                    onChange={lambda e: any -> None { setUsername(e.target.value); }}
                />
            </div>
            <div style={{"marginBottom": "20px"}}>
                <label style={{"display": "block", "marginBottom": "8px", "fontWeight": "500"}}>Password</label>
                <Input
                    id="login-password"
                    type="password"
                    value={password()}
                    onChange={lambda e: any -> None { setPassword(e.target.value); }}
                />
            </div>
            <Button label="Sign In" type="submit" style={{"width": "100%"}} />
        </form>
        <p style={{"textAlign": "center", "marginTop": "20px", "color": "#6b7280"}}>
            Don't have an account? <Link href="/signup" style={{"color": "#7C3AED", "textDecoration": "none"}}>Sign up</Link>
        </p>
    </Card>;
}
