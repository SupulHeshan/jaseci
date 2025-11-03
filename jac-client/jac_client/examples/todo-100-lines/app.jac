node Todo {
    has text: str;
    has done: bool = False;
}

walker create_todo {
    can create with `root entry {
        new_todo = here ++> Todo("Example Todo");
        report new_todo;
    }
}

walker toggle_todo {
    can toggle with Todo entry {
        here.done = not here.done;
        report here;
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

cl {
    let [todoState, setTodoState] = createState({"items": []});

    async def onAddTodo(e: any) -> None {
        e.preventDefault();
        inputEl = document.getElementById("todo-input");
        text = (inputEl.value if inputEl and inputEl.value else "").trim();
        if not text { return; }
        new_todo = await __jacSpawn("create_todo", {"text": text});
        s = todoState();
        setTodoState({"items": s.items.concat([{"id": new_todo.reports[0][0]._jac_id, "text": new_todo.reports[0][0].text, "done": new_todo.reports[0][0].done}])});
        if inputEl { inputEl.value = ""; }
    }

    async def toggleTodo(id: any) -> None {
        toggled_todo = await __jacSpawn("toggle_todo", {}, id);
        s = todoState();
        updated = [];
        for item in s.items {
            if item.id == id { updated.push({"id": item.id, "text": item.text, "done": not item.done}); }
            else { updated.push(item); }
        }
        setTodoState({"items": updated});
    }

    def removeTodo(id: any) -> None {
        s = todoState();
        remaining = [];
        for item in s.items { if item.id != id { remaining.push(item); } }
        setTodoState({"items": remaining});
    }

    async def read_todos_action() -> None {
        todos = await __jacSpawn("read_todos");
        items = [];
        for todo in todos.reports { items.push({"id": todo._jac_id, "text": todo.text, "done": todo.done}); }
        setTodoState({"items": items});
    }

    def TodoApp() -> any {
        s = todoState();
        onMount(lambda -> None { read_todos_action(); });
        children = [];
        for item in s.items { children.push(<li key={item.id} style={{"display": "flex", "gap": "12px", "alignItems": "center", "padding": "10px", "marginBottom": "8px", "background": "#f9fafb", "borderRadius": "4px"}}>
            <input type="checkbox" checked={item.done} onChange={lambda -> None { toggleTodo(item.id); }} style={{"cursor": "pointer"}}/>
            <span style={{"flex": "1", "textDecoration": ("line-through" if item.done else "none")}}>{item.text}</span>
            <button onClick={lambda -> None { removeTodo(item.id); }} style={{"padding": "6px 12px", "background": "#ef4444", "color": "white", "border": "none", "borderRadius": "4px", "cursor": "pointer"}}>Remove</button>
        </li>); }
        return <div style={{"maxWidth": "600px", "margin": "40px auto", "padding": "24px", "fontFamily": "system-ui"}}>
            <div style={{"display": "flex", "justifyContent": "space-between", "alignItems": "center", "marginBottom": "20px"}}>
                <h2 style={{"margin": "0"}}>My Todos</h2>
                <button onClick={lambda -> None { jacLogout(); navigate("/login"); }} style={{"padding": "8px 16px", "background": "#ef4444", "color": "white", "border": "none", "borderRadius": "4px", "cursor": "pointer"}}>Logout</button>
            </div>
            <form onSubmit={onAddTodo} style={{"display": "flex", "gap": "8px", "marginBottom": "16px"}}>
                <input id="todo-input" type="text" placeholder="Add todo..." style={{"flex": "1", "padding": "10px", "border": "1px solid #ddd", "borderRadius": "4px"}}/>
                <button type="submit" style={{"padding": "10px 20px", "background": "#7C3AED", "color": "white", "border": "none", "borderRadius": "4px", "cursor": "pointer"}}>Add</button>
            </form>
            <ul style={{"listStyle": "none", "padding": "0"}}>{children}</ul>
        </div>;
    }

    async def handle_login(e: any) -> None {
        e.preventDefault();
        username = document.getElementById("login-username").value;
        password = document.getElementById("login-password").value;
        if await jacLogin(username, password) { navigate("/todos"); } else { alert("Login failed"); }
    }

    async def handle_signup(e: any) -> None {
        e.preventDefault();
        username = document.getElementById("signup-username").value;
        password = document.getElementById("signup-password").value;
        confirm = document.getElementById("signup-password-confirm").value;
        if password != confirm { alert("Passwords do not match"); return; }
        result = await jacSignup(username, password);
        if result["success"] if "success" in result else False { navigate("/todos"); } else { alert(result["error"] if "error" in result else "Signup failed"); }
    }

    def LoginForm() -> any {
        return <div style={{"maxWidth": "400px", "margin": "60px auto", "padding": "24px", "fontFamily": "system-ui"}}>
            <h2 style={{"textAlign": "center", "marginBottom": "20px"}}>Login</h2>
            <form onSubmit={handle_login}>
                <input id="login-username" type="text" placeholder="Username" style={{"width": "100%", "padding": "10px", "marginBottom": "12px", "border": "1px solid #ddd", "borderRadius": "4px", "boxSizing": "border-box"}}/>
                <input id="login-password" type="password" placeholder="Password" style={{"width": "100%", "padding": "10px", "marginBottom": "16px", "border": "1px solid #ddd", "borderRadius": "4px", "boxSizing": "border-box"}}/>
                <button type="submit" style={{"width": "100%", "padding": "10px", "background": "#7C3AED", "color": "white", "border": "none", "borderRadius": "4px", "cursor": "pointer"}}>Sign In</button>
            </form>
            <p style={{"textAlign": "center", "marginTop": "16px"}}><Link href="/signup" style={{"color": "#7C3AED", "textDecoration": "none"}}>Create an account</Link></p>
        </div>;
    }

    def SignupForm() -> any {
        return <div style={{"maxWidth": "400px", "margin": "60px auto", "padding": "24px", "fontFamily": "system-ui"}}>
            <h2 style={{"textAlign": "center", "marginBottom": "20px"}}>Sign Up</h2>
            <form onSubmit={handle_signup}>
                <input id="signup-username" type="text" placeholder="Username" required style={{"width": "100%", "padding": "10px", "marginBottom": "12px", "border": "1px solid #ddd", "borderRadius": "4px", "boxSizing": "border-box"}}/>
                <input id="signup-password" type="password" placeholder="Password" required style={{"width": "100%", "padding": "10px", "marginBottom": "12px", "border": "1px solid #ddd", "borderRadius": "4px", "boxSizing": "border-box"}}/>
                <input id="signup-password-confirm" type="password" placeholder="Confirm Password" required style={{"width": "100%", "padding": "10px", "marginBottom": "16px", "border": "1px solid #ddd", "borderRadius": "4px", "boxSizing": "border-box"}}/>
                <button type="submit" style={{"width": "100%", "padding": "10px", "background": "#7C3AED", "color": "white", "border": "none", "borderRadius": "4px", "cursor": "pointer"}}>Create Account</button>
            </form>
            <p style={{"textAlign": "center", "marginTop": "16px"}}><Link href="/login" style={{"color": "#7C3AED", "textDecoration": "none"}}>Already have an account? Login</Link></p>
        </div>;
    }

    def App() -> any {
        login_route = {"path": "/login", "component": lambda -> any { return LoginForm(); }, "guard": None};
        signup_route = {"path": "/signup", "component": lambda -> any { return SignupForm(); }, "guard": None};
        todos_route = {"path": "/todos", "component": lambda -> any { return TodoApp(); }, "guard": jacIsLoggedIn};
        routes = [login_route, signup_route, todos_route];
        router = initRouter(routes, "/login");
        return <div>{router.render()}</div>;
    }

    def jac_app() -> any { return App(); }
}