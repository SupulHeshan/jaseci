# ============================================================================
# BACKEND: Data Models & Business Logic (like Next.js API routes/models)
# ============================================================================

node Todo {
    has text: str;
    has done: bool = False;
}

walker create_todo {
    can create with `root entry {
        new_todo = here ++> Todo(text="Example todo");
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
    # Shared State Management (like Redux or Zustand)
    # ============================================================================

    let [authFormState, setAuthFormState] = createState({"username": "", "password": "", "confirmPassword": "", "error": ""});
    let [todoState, setTodoState] = createState({"items": [], "loading": False, "error": None});
    let [todoFormState, setTodoFormState] = createState({"inputValue": ""});

    # ============================================================================
    # Common Form Handlers
    # ============================================================================

    def handleFormChange(field: str, value: any) -> None {
        console.log(f"Field {field} changed:", value);
        if field == "username" {
            setAuthFormState({"username": value});
        } elif field == "password" {
            setAuthFormState({"password": value});
        } elif field == "confirmPassword" {
            setAuthFormState({"confirmPassword": value});
        } elif field == "todoinput" {
            setTodoFormState({"inputValue": value});
        }
    }
    def handleTodoFormChange(value: any) -> None {
        console.log(f"Field todo input changed:", value);
         setTodoFormState({"inputValue": value});
    }

    def clearAuthError() -> None {
        setAuthFormState({"error": ""});
    }

    # ============================================================================
    # Custom Hooks (like React custom hooks)
    # ============================================================================

    def useTodos() -> dict {
        async def fetchTodos() -> None {
            setTodoState({"loading": True});
            try {
                result = await __jacSpawn("read_todos");
                items = [];
                for todo in result.reports {
                    items.push({"id": todo._jac_id, "text": todo.text, "done": todo.done});
                }
                setTodoState({"items": items, "loading": False, "error": None});
            } except Exception as err {
                setTodoState({"loading": False, "error": str(err)});
            }
        }

        async def addTodo(text: str) -> None {
            if not text.trim() { return; }
            try {
                result = await __jacSpawn("create_todo", {"text": text});
                console.log("Add todo result:", result);

                if result.reports && result.reports.length > 0 && result.reports[0].length > 0 {
                    todo = result.reports[0][0];
                    currentState = todoState();
                    newTodo = {"id": todo._jac_id, "text": todo.text, "done": todo.done};
                    setTodoState({"items": currentState.items.concat([newTodo])});
                }
            } except Exception as err {
                console.log("Add todo error:", err);
                setTodoState({"error": str(err)});
            }
        }

        async def toggleTodo(id: any) -> None {
            try {
                await __jacSpawn("toggle_todo", {}, id);
                currentState = todoState();
                updated = [];
                for item in currentState.items {
                    if item.id == id {
                        updated.push({"id": item.id, "text": item.text, "done": not item.done});
                    } else {
                        updated.push(item);
                    }
                }
                setTodoState({"items": updated});
            } except Exception as err {
                setTodoState({"error": str(err)});
            }
        }

        async def deleteTodo(id: any) -> None {
            try {
                await __jacSpawn("delete_todo", {}, id);
                currentState = todoState();
                remaining = [];
                for item in currentState.items { if item.id != id { remaining.push(item); } }
                setTodoState({"items": remaining});
            } except Exception as err {
                setTodoState({"error": str(err)});
            }
        }

        return {
            "todos": lambda -> any { return todoState(); },
            "fetchTodos": fetchTodos,
            "addTodo": addTodo,
            "toggleTodo": toggleTodo,
            "deleteTodo": deleteTodo
        };
    }

    def useAuth() -> dict {
        async def login(username: str, password: str) -> dict {
            try {
                result = await jacLogin(username, password);
                console.log("Login result:", result);
                return {"success": result, "data": result, "error": None};
            } except Exception as err {
                return {"success": False, "error": "Invalid credentials"};
            }
        }

        async def signup(username: str, password: str, confirmPassword: str) -> dict {
            if password != confirmPassword {
                return {"success": False, "error": "Passwords do not match"};
            }
            try {
                result = await jacSignup(username, password);
                return {"success": result, "data": result, "error": None};
            } except Exception as err {
                return {"success": False, "error": str(err)};
            }
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
        def noop() -> None { }

        label = props["label"] || props["children"] || "";
        onClick = props["onClick"] || noop;
        variant = props["variant"] || "primary";
        disabled = props["disabled"] || False;
        type = props["type"] || "button";
        style = props["style"] || {};

        variantStyles = {
            "primary": {"background": "#7C3AED", "color": "white"},
            "danger": {"background": "#ef4444", "color": "white"},
            "secondary": {"background": "#6b7280", "color": "white"}
        };

        baseStyle = {
            "padding": "10px 20px",
            "border": "none",
            "borderRadius": "4px",
            "cursor": ("not-allowed" if disabled else "pointer"),
            "opacity": (0.6 if disabled else 1),
            "fontWeight": "500",
            "transition": "all 0.2s ease"
        };
        selectedVariant = variantStyles[variant] || variantStyles["primary"];
        mergedStyle = {};
        for key in Object.keys(baseStyle) { mergedStyle[key] = baseStyle[key]; }
        for key in Object.keys(selectedVariant) { mergedStyle[key] = selectedVariant[key]; }
        for key in Object.keys(style) { mergedStyle[key] = style[key]; }

        return <button onClick={onClick} disabled={disabled} type={type} style={mergedStyle}>{label}</button>;
    }

    def Input(props: dict) -> any {
        def noop() -> None { }

        value = props["value"] || "";
        onChange = props["onChange"] || noop;
        placeholder = props["placeholder"] || "";
        type = props["type"] || "text";
        disabled = props["disabled"] || False;
        style = props["style"] || {};
        id = props["id"] || "";
        required = props["required"] || False;

        baseStyle = {
            "padding": "12px 16px",
            "border": "1px solid #E5E7EB",
            "borderRadius": "8px",
            "fontSize": "16px",
            "background": "#FFFFFF",
            "color": "#111827",
            "outline": "none",
            "boxSizing": "border-box",
            "transition": "all 0.2s ease",
            "opacity": (0.6 if disabled else 1),
            "cursor": ("not-allowed" if disabled else "text")
        };

        mergedStyle = {};
        for key in Object.keys(baseStyle) { mergedStyle[key] = baseStyle[key]; }
        for key in Object.keys(style) { mergedStyle[key] = style[key]; }

        return <input
            type={type}
            value={value}
            onChange={onChange}
            placeholder={placeholder}
            disabled={disabled}
            style={mergedStyle}
            id={id}
            required={required}
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

        if (items).length == 0 {
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
        value = props["value"] || "";
        onChange = props["onChange"];

        def handleSubmit(e: any) -> None {
            e.preventDefault();
            text = value.trim();
            if text {
                onSubmit(text);
            }
        }

        return <form onSubmit={handleSubmit} style={{"display": "flex", "gap": "8px", "marginBottom": "20px"}}>
            <Input
                value={value}
                onChange={onChange}
                placeholder="What needs to be done?"
                id="todo-input"
                style={{"width": "100%"}}

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

    async def handleAuthSubmit(isLogin: bool = True) -> None {
        clearAuthError();
        currentState = authFormState();
        auth = useAuth();

        try {
            result = {};
            if isLogin {
                result = await auth["login"](currentState.username, currentState.password);
            } else {
                result = await auth["signup"](currentState.username, currentState.password, currentState.confirmPassword);
            }

            console.log("Auth result:", result);
            if result["success"] {
                console.log("Authentication successful");
                # Clear form on successful authentication
                setAuthFormState({"username": "", "password": "", "confirmPassword": "", "error": ""});
                navigate("/todos");
            } else {
                setAuthFormState({"error": result["error"] if result["error"] else "Authentication failed"});
            }
        } except Exception as err {
            console.log("Auth error:", err);
            setAuthFormState({"error": str(err)});
        }
    }

    def LoginPage() -> any {
        currentState = authFormState();

        async def handleSubmit(e: any) -> None {
            e.preventDefault();
            await handleAuthSubmit(True);
        }

        errorElement = <div></div>;
        if currentState.error {
            errorElement = <div style={{"padding": "12px", "background": "#fee2e2", "color": "#dc2626", "borderRadius": "6px", "marginBottom": "16px"}}>{ currentState.error }</div>;
        }

        return <Card>
            <h2 style={{"textAlign": "center", "marginBottom": "24px"}}>Welcome Back</h2>
            {errorElement}
            <form onSubmit={handleSubmit}>
                <div style={{"marginBottom": "16px"}}>
                    <label htmlFor="login-username" style={{"display": "block", "marginBottom": "8px", "fontWeight": "500"}}>Username</label>
                    <Input
                        id="login-username"
                        value={currentState.username}
                        onChange={lambda e: any -> None { handleFormChange("username", e.target.value); }}
                        placeholder="Enter your username"
                        style={{"width": "100%"}}

                    />
                </div>
                <div style={{"marginBottom": "20px"}}>
                    <label htmlFor="login-password" style={{"display": "block", "marginBottom": "8px", "fontWeight": "500"}}>Password</label>
                    <Input
                        id="login-password"
                        type="password"
                        value={currentState.password}
                        onChange={lambda e: any -> None { handleFormChange("password", e.target.value); }}
                        placeholder="Enter your password"
                        style={{"width": "100%"}}

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
        currentState = authFormState();

        async def handleSubmit(e: any) -> None {
            e.preventDefault();
            await handleAuthSubmit(False);
        }

        errorElement = None;
        if currentState.error {
            errorElement = <div style={{"padding": "12px", "background": "#fee2e2", "color": "#dc2626", "borderRadius": "6px", "marginBottom": "16px"}}>{ currentState.error }</div>;
        }

        return <Card>
            <h2 style={{"textAlign": "center", "marginBottom": "24px"}}>Create Account</h2>
            {errorElement}
            <form onSubmit={handleSubmit}>
                <div style={{"marginBottom": "16px"}}>
                    <label htmlFor="signup-username" style={{"display": "block", "marginBottom": "8px", "fontWeight": "500"}}>Username</label>
                    <Input
                        id="signup-username"
                        value={currentState.username}
                        onChange={lambda e: any -> None { handleFormChange("username", e.target.value); }}
                        style={{"width": "100%"}}
                        placeholder="Enter your username"
                    />
                </div>
                <div style={{"marginBottom": "16px"}}>
                    <label htmlFor="signup-password" style={{"display": "block", "marginBottom": "8px", "fontWeight": "500"}}>Password</label>
                    <Input
                        id="signup-password"
                        type="password"
                        value={currentState.password}
                        onChange={lambda e: any -> None { handleFormChange("password", e.target.value); }}
                        style={{"width": "100%"}}
                        placeholder="Enter your password"

                    />
                </div>
                <div style={{"marginBottom": "20px"}}>
                    <label htmlFor="signup-password-confirm" style={{"display": "block", "marginBottom": "8px", "fontWeight": "500"}}>Confirm Password</label>
                    <Input
                        id="signup-password-confirm"
                        type="password"
                        value={currentState.confirmPassword}
                        onChange={lambda e: any -> None { handleFormChange("confirmPassword", e.target.value); }}
                        style={{"width": "100%"}}
                        placeholder="Enter your password confirmation"

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
        currentState = todoFormState();

        def handleTodoSubmit(text: str) -> None {
            todosHook["addTodo"](text);
            setTodoFormState({"inputValue": ""});
        }

        def handleTodoChange(e: any) -> None {
            handleTodoFormChange(e.target.value);
        }

        errorElement = None;
        if state.error {
            errorElement = <div style={{"padding": "12px", "background": "#fee2e2", "color": "#dc2626", "borderRadius": "6px", "marginBottom": "16px"}}>{ state.error }</div>;
        }

        return <div style={{"maxWidth": "800px", "margin": "40px auto", "padding": "0 24px"}}>
            <Card title="My Todos">
                <div style={{"display": "flex", "justifyContent": "space-between", "alignItems": "center", "marginBottom": "20px"}}>
                    <span style={{"color": "#6b7280", "fontSize": "14px"}}>
                        {(state.items).length} {"todo" if (state.items).length == 1 else "todos"}
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

                {errorElement}

                <TodoForm
                    onSubmit={handleTodoSubmit}
                    value={currentState.inputValue}
                    onChange={handleTodoChange}
                />

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
