cl import from .hook_useAuth { useAuth }
cl import from .component_card { Card }
cl import from .component_input { Input }
cl import from .component_button { Button }

cl def SignupPage() -> any {
    auth = useAuth();
    let [username, setUsername] = createState("");
    let [password, setPassword] = createState("");
    let [confirmPassword, setConfirmPassword] = createState("");
    let [error, setError] = createState("");
    
    async def handleSubmit(e: any) -> None {
        e.preventDefault();
        result = await auth["signup"](username(), password(), confirmPassword());
        if result["success"] {
            navigate("/todos");
        } else {
            setError(result["error"] if result["error"] else "Signup failed");
        }
    }
    
    return <Card>
        <h2 style={{"textAlign": "center", "marginBottom": "24px"}}>Create Account</h2>
        {error() ? <div style={{"padding": "12px", "background": "#fee2e2", "color": "#dc2626", "borderRadius": "6px", "marginBottom": "16px"}}>{error()}</div> : None}
        <form onSubmit={handleSubmit}>
            <div style={{"marginBottom": "16px"}}>
                <label style={{"display": "block", "marginBottom": "8px", "fontWeight": "500"}}>Username</label>
                <Input
                    id="signup-username"
                    value={username()}
                    onChange={lambda e: any -> None { setUsername(e.target.value); }}
                />
            </div>
            <div style={{"marginBottom": "16px"}}>
                <label style={{"display": "block", "marginBottom": "8px", "fontWeight": "500"}}>Password</label>
                <Input
                    id="signup-password"
                    type="password"
                    value={password()}
                    onChange={lambda e: any -> None { setPassword(e.target.value); }}
                />
            </div>
            <div style={{"marginBottom": "20px"}}>
                <label style={{"display": "block", "marginBottom": "8px", "fontWeight": "500"}}>Confirm Password</label>
                <Input
                    id="signup-password-confirm"
                    type="password"
                    value={confirmPassword()}
                    onChange={lambda e: any -> None { setConfirmPassword(e.target.value); }}
                />
            </div>
            <Button label="Create Account" type="submit" style={{"width": "100%"}} />
        </form>
        <p style={{"textAlign": "center", "marginTop": "20px", "color": "#6b7280"}}>
            Already have an account? <Link href="/login" style={{"color": "#7C3AED", "textDecoration": "none"}}>Login</Link>
        </p>
    </Card>;
}
