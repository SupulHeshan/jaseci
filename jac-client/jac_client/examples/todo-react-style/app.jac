# ============================================================================
# BACKEND: Data Models & Business Logic (like Next.js API routes/models)
# ============================================================================

node Todo {
    has text: str;
    has done: bool = False;
}

walker create_todo {
    can create with `root entry {
        new_todo = here ++> Todo(text=visitor.text);
        report new_todo;
    }
}

walker toggle_todo {
    can toggle with Todo entry {
        here.done = not here.done;
        report here;
    }
}

walker delete_todo {
    can delete with Todo entry {
        del here;
        report {"success": True};
    }
}

walker read_todos {
    can read with `root entry {
        visit [-->(`?Todo)];
    }
    can report_todos with Todo entry {
        report here;
    }
}

# ============================================================================
# FRONTEND: React-Style Components & Hooks
# ============================================================================

cl {
    # ============================================================================
    # Custom Hooks (like React custom hooks)
    # ============================================================================

    def useTodos() -> dict {
        let [todos, setTodos] = createState({"items": [], "loading": False, "error": None});

        async def fetchTodos() -> None {
            setTodos({"loading": True, "error": None});
            try {
                result = await __jacSpawn("read_todos");
                items = [];
                for todo in result.reports {
                    items.push({"id": todo._jac_id, "text": todo.text, "done": todo.done});
                }
                setTodos({"items": items, "loading": False, "error": None});
            } except Exception as err {
                setTodos({"loading": False, "error": str(err)});
            }
        }

        async def addTodo(text: str) -> None {
            if not text.trim() { return; }
            try {
                result = await __jacSpawn("create_todo", {"text": text});
                todo = result.reports[0][0] if result.reports and len(result.reports) > 0 else None;
                if todo {
                    state = todos();
                    setTodos({"items": state.items.concat([{"id": todo.reports[0][0]._jac_id, "text": todo.reports[0][0].text, "done": todo.reports[0][0].done}])});
                }
            } except Exception as err {
                setTodos({"error": str(err)});
            }
        }

        async def toggleTodo(id: any) -> None {
            try {
                await __jacSpawn("toggle_todo", {}, id);
                state = todos();
                updated = [];
                for item in state.items {
                    if item.id == id {
                        updated.push({"id": item.id, "text": item.text, "done": not item.done});
                    } else {
                        updated.push(item);
                    }
                }
                setTodos({"items": updated});
            } except Exception as err {
                setTodos({"error": str(err)});
            }
        }

        async def deleteTodo(id: any) -> None {
            try {
                await __jacSpawn("delete_todo", {}, id);
                state = todos();
                remaining = [];
                for item in state.items { if item.id != id { remaining.push(item); } }
                setTodos({"items": remaining});
            } except Exception as err {
                setTodos({"error": str(err)});
            }
        }

        return {
            "todos": todos,
            "fetchTodos": fetchTodos,
            "addTodo": addTodo,
            "toggleTodo": toggleTodo,
            "deleteTodo": deleteTodo
        };
    }

    def useAuth() -> dict {
        async def login(username: str, password: str) -> dict {
            success = await jacLogin(username, password);
            return {"success": success, "error": None if success else "Invalid credentials"};
        }

        async def signup(username: str, password: str, confirmPassword: str) -> dict {
            if password != confirmPassword {
                return {"success": False, "error": "Passwords do not match"};
            }
            result = await jacSignup(username, password);
            return {"success": result["success"] if "success" in result else False, "error": result["error"] if "error" in result else None};
        }

        def logout() -> None {
            jacLogout();
        }

        def isAuthenticated() -> bool {
            return jacIsLoggedIn();
        }

        return {"login": login, "signup": signup, "logout": logout, "isAuthenticated": isAuthenticated};
    }

    # ============================================================================
    # UI Components (like React components)
    # ============================================================================

    def Button(props: dict) -> any {
        label = props["label"] || props["children"] || "";
        onClick = props["onClick"];
        variant = props["variant"] || "primary";
        disabled = props["disabled"] || False;

        variantStyles = {
            "primary": {"background": "#7C3AED", "color": "white"},
            "danger": {"background": "#ef4444", "color": "white"},
            "secondary": {"background": "#6b7280", "color": "white"}
        };

        baseStyle = {
            "padding": "10px 20px",
            "border": "none",
            "borderRadius": "4px",
            "cursor": "not-allowed" if disabled else "pointer",
            "opacity": 0.6 if disabled else 1,
            "fontWeight": "500",
            "transition": "all 0.2s ease"
        };
        selectedVariant = variantStyles[variant] || variantStyles["primary"];
        style = {};
        for key in Object.keys(baseStyle) { style[key] = baseStyle[key]; }
        for key in Object.keys(selectedVariant) { style[key] = selectedVariant[key]; }

        return <button onClick={onClick} disabled={disabled} style={style}>{label}</button>;
    }

    def Input(props: dict) -> any {
        value = props["value"] || "";
        onChange = props["onChange"];
        placeholder = props["placeholder"] || "";
        id = props["id"] || "";
        type = props["type"] || "text"; 
        console.log("value inside custom input", value);
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

    def TodoItem(props: dict) -> any {
        item = props["item"];
        onToggle = props["onToggle"];
        onDelete = props["onDelete"];

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
                checked={ "checked" if item.done else "unchecked"}
                onChange={lambda -> None { onToggle(item.id); }}
                style={{"cursor": "pointer", "width": "18px", "height": "18px"}}
            />
            <span style={{
                "flex": "1",
                "textDecoration": "line-through" if item.done else "none",
                "color": "#9ca3af" if item.done else "#111827",
                "fontSize": "16px"
            }}>
                {item.text}
            </span>
            <Button label="Delete" variant="danger" onClick={onDelete} />
        </li>;
    }

    def TodoList(props: dict) -> any {
        items = props["items"] || [];
        onToggle = props["onToggle"];
        onDelete = props["onDelete"];

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

    def TodoForm(props: dict) -> any {
        onSubmit = props["onSubmit"];
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
                onChange={lambda v: str -> None { setInputValue(v); }}
                placeholder="What needs to be done?"
                id="todo-input"
            />
            <Button label="Add Todo" type="submit" />
        </form>;
    }

    def Card(props: dict) -> any {
        children = props["children"];
        title = props["title"] || "";

        return <div style={{
            "maxWidth": "600px",
            "margin": "0 auto",
            "padding": "24px",
            "background": "white",
            "borderRadius": "12px",
            "boxShadow": "0 1px 3px rgba(0,0,0,0.1)",
            "fontFamily": "system-ui, -apple-system, sans-serif"
        }}>
            {<h2 style={{"marginTop": "0", "marginBottom": "20px", "color": "#111827"}}>{ title }</h2>}
            {children}
        </div>;
    }

    # ============================================================================
    # Pages (like Next.js pages)
    # ============================================================================

    def LoginPage() -> any {
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
            {<div style={{"padding": "12px", "background": "#fee2e2", "color": "#dc2626", "borderRadius": "6px", "marginBottom": "16px"}}>{ error() }</div>}
            <form onSubmit={handleSubmit}>
                <div style={{"marginBottom": "16px"}}>
                    <label style={{"display": "block", "marginBottom": "8px", "fontWeight": "500"}}>Username</label>
                    <Input
                        id="login-username"
                        value={username()}
                        onChange={lambda v: str -> None { setUsername(v); }}
                    />
                </div>
                <div style={{"marginBottom": "20px"}}>
                    <label style={{"display": "block", "marginBottom": "8px", "fontWeight": "500"}}>Password</label>
                    <Input
                        id="login-password"
                        type="password"
                        value={password()}
                        onChange={lambda v: str -> None { setPassword(v); }}
                    />
                </div>
                <Button label="Sign In" type="submit" style={{"width": "100%"}} />
            </form>
            <p style={{"textAlign": "center", "marginTop": "20px", "color": "#6b7280"}}>
                Don't have an account? <Link href="/signup" style={{"color": "#7C3AED", "textDecoration": "none"}}>Sign up</Link>
            </p>
        </Card>;
    }

    def SignupPage() -> any {
        auth = useAuth();
        let [formState, setFormState] = createState({"username": "temp", "password": "", "confirmPassword": "", "error": ""});
        async def handleSubmit(e: any) -> None {
            e.preventDefault();
            result = await auth["signup"](formState_state.username, formState_state.password, formState_state.confirmPassword);
            if result["success"] {
                navigate("/todos");
            } else {
                setFormState({"error": result["error"] if result["error"] else "Signup failed"});
            }
        }
        formState_state = formState();

        def handleUsernameChange (e: any) -> None {
            setFormState({"username": e.target.value});
        } 
        return <Card> 
            <h2 style={{"textAlign": "center", "marginBottom": "24px"}}>Create Account</h2>
            {<div style={{"padding": "12px", "background": "#fee2e2", "color": "#dc2626", "borderRadius": "6px", "marginBottom": "16px"}}>{ formState["error"] }</div>}
            <form onSubmit={handleSubmit}>
                <div style={{"marginBottom": "16px"}}>
                    <label style={{"display": "block", "marginBottom": "8px", "fontWeight": "500"}}>Username</label>
                    <Input
                        id="signup-username"
                        value={formState_state.username}
                        onChange={lambda v: str -> None { handleUsernameChange(v); }}
                    />
                </div>
                <div style={{"marginBottom": "16px"}}>
                    <label style={{"display": "block", "marginBottom": "8px", "fontWeight": "500"}}>Password</label>
                    <Input
                        id="signup-password"
                        type="password"
                        value={formState_state.password}
                        onChange={lambda v: str -> None { setFormState({"password": v}); }}
                    />
                </div>
                <div style={{"marginBottom": "20px"}}>
                    <label style={{"display": "block", "marginBottom": "8px", "fontWeight": "500"}}>Confirm Password</label>
                    <Input
                        id="signup-password-confirm"
                        type="password"
                        value={formState_state.confirmPassword}
                        onChange={lambda v: str -> None { setFormState({"confirmPassword": v}); }}
                    />
                </div>
                <Button label="Create Account" type="submit" style={{"width": "100%"}} />
            </form>
            <p style={{"textAlign": "center", "marginTop": "20px", "color": "#6b7280"}}>
                Already have an account? <Link href="/login" style={{"color": "#7C3AED", "textDecoration": "none"}}>Login</Link>
            </p>
        </Card>;
    }

    def TodosPage() -> any {
        auth = useAuth();
        todosHook = useTodos();

        onMount(lambda -> None {
            todosHook["fetchTodos"]();
        });

        state = todosHook["todos"]();

        return <div style={{"maxWidth": "800px", "margin": "40px auto", "padding": "0 24px"}}>
            <Card title="My Todos">
                <div style={{"display": "flex", "justifyContent": "space-between", "alignItems": "center", "marginBottom": "20px"}}>
                    <span style={{"color": "#6b7280", "fontSize": "14px"}}>
                        {len(state.items)} {"todo" if len(state.items) == 1 else "todos"}
                    </span>
                    <Button
                        label="Logout"
                        variant="secondary"
                        onClick={lambda -> None {
                            auth["logout"]();
                            navigate("/login");
                        }}
                    />
                </div>

                {<div style={{"padding": "12px", "background": "#fee2e2", "color": "#dc2626", "borderRadius": "6px", "marginBottom": "16px"}}>{ state.error }</div>}

                <TodoForm onSubmit={todosHook["addTodo"]} />

                #  <div style={{"textAlign": "center", "padding": "40px", "color": "#9ca3af"}}>{ "Loading..." if state.loading else None }</div>

                {<TodoList
                    items={state.items}
                    onToggle={todosHook["toggleTodo"]}
                    onDelete={todosHook["deleteTodo"]}/>}
            </Card>
        </div>;
    }

    # ============================================================================
    # App Layout & Routing (like Next.js _app.tsx)
    # ============================================================================

    def App() -> any {
        loginRoute = {"path": "/login", "component": lambda -> any { return LoginPage(); }, "guard": None};
        signupRoute = {"path": "/signup", "component": lambda -> any { return SignupPage(); }, "guard": None};
        todosRoute = {"path": "/todos", "component": lambda -> any { return TodosPage(); }, "guard": jacIsLoggedIn};

        routes = [loginRoute, signupRoute, todosRoute];
        router = initRouter(routes, "/login");

        return <div style={{"minHeight": "100vh", "background": "#f9fafb"}}>
            {router.render()}
        </div>;
    }

    def jac_app() -> any {
        return App();
    }
}
