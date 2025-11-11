# Todo App
cl import from react {useState, useEffect, useMemo, useContext, useRef}
cl import from "@jac-client/utils" {Router, Routes, Route, Link, Navigate, useNavigate, jacIsLoggedIn, jacLogin, jacSignup, __jacSpawn, jacLogout}
node Todo {
    has text: str;
    has done: bool = False;
}

walker create_todo {
    has text:str;
    class __specs__ {
        has auth: bool = True;
    }
    can create with `root entry {
        new_todo = here ++> Todo(text= self.text);
        report new_todo;
    }
}
walker toggle_todo {
    class __specs__ {
        has auth: bool = True;
    }
    can toggle with Todo entry {
        here.done = not here.done;
        report here;
    }
}
walker read_todos {
    class __specs__ {
        has auth: bool = True;
    }
    can read with `root entry {
        visit [-->(`?Todo)];
    }
    can report_todos with exit {
        report here;
    }
}

cl {
    def useAuth() -> dict {
        async def login(username: str, password: str) -> dict {
            try {
                result = await jacLogin(username, password);
                if result {
                    return {"success": True, "data": result, "error": None};
                }
                return {"success": False, "error": "Invalid credentials"};
            } except Exception {
                return {"success": False, "error": "Invalid credentials"};
            }
        }

        async def signup(username: str, password: str, confirmPassword: str) -> dict {
            if password != confirmPassword {
                return {"success": False, "error": "Passwords do not match"};
            }
            try {
                result = await jacSignup(username, password);
                success = False;
                message = "";
                if result && not Array.isArray(result) {
                    if result["success"] {
                        success = True;
                    } elif result["token"] {
                        success = True;
                    }
                    if result["error"] {
                        message = result["error"];
                    }
                } else {
                    if result {
                        success = True;
                    }
                }
                if success {
                    return {"success": True, "data": result, "error": None};
                }
                fallback = message if message != "" else "Unable to create account";
                return {"success": False, "error": fallback};
            } except Exception as err {
                return {"success": False, "error": err.toString()};
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

    def useTodos() -> dict {
        let [state, setState] = useState({
            "todos": [],
            "inputValue": "",
            "filter": "all",
            "loading": False,
            "error": ""
        });

        def flattenReports(raw: any) -> list {
            if not raw {
                return [];
            }
            if Array.isArray(raw) {
                accumulator = [];
                raw.forEach(lambda entry: any -> None {
                    if Array.isArray(entry) {
                        entry.forEach(lambda nested: any -> None {
                            if nested {
                                accumulator.push(nested);
                            }
                        });
                    } elif entry {
                        accumulator.push(entry);
                    }
                });
                return accumulator;
            }
            return [raw];
        }

        def setLoading(loading: bool) -> None {
            current = state;
            nextState = {
                "todos": current["todos"],
                "inputValue": current["inputValue"],
                "filter": current["filter"],
                "loading": loading,
                "error": current["error"]
            };
            setState(nextState);
        }

        def setError(message: str) -> None {
            current = state;
            nextState = {
                "todos": current["todos"],
                "inputValue": current["inputValue"],
                "filter": current["filter"],
                "loading": current["loading"],
                "error": message
            };
            setState(nextState);
        }

        async def loadTodos() -> None {
            current = state;
            setState({
                "todos": current["todos"],
                "inputValue": current["inputValue"],
                "filter": current["filter"],
                "loading": True,
                "error": current["error"]
            });
            try {
                response = await __jacSpawn("read_todos", "", {});
                items = flattenReports(response.reports);
                setState({
                    "todos": items,
                    "inputValue": current["inputValue"],
                    "filter": current["filter"],
                    "loading": False,
                    "error": ""
                });
            } except Exception as err {
                setState({
                    "todos": current["todos"],
                    "inputValue": current["inputValue"],
                    "filter": current["filter"],
                    "loading": False,
                    "error": err.toString()
                });
            }
        }

        async def addTodo() -> None {
            current = state;
            text = current["inputValue"].trim();
            if not text {
                return;
            }
            try {
                result = await __jacSpawn("create_todo", "", {"text": text});
                reportItems = flattenReports(result.reports);
                created = None;
                if reportItems.length > 0 {
                    created = reportItems[0];
                }
                if created {
                    updatedTodos = current["todos"].concat([created]);
                    setState({
                        "todos": updatedTodos,
                        "inputValue": "",
                        "filter": current["filter"],
                        "loading": False,
                        "error": ""
                    });
                } else {
                    await loadTodos();
                }
            } except Exception as err {
                setState({
                    "todos": current["todos"],
                    "inputValue": current["inputValue"],
                    "filter": current["filter"],
                    "loading": False,
                    "error": err.toString()
                });
            }
        }

        async def toggleTodo(id: any) -> None {
            current = state;
            try {
                result = await __jacSpawn("toggle_todo", id, {});
                reportItems = flattenReports(result.reports);
                updated = None;
                if reportItems.length > 0 {
                    updated = reportItems[0];
                }
                transformed = current["todos"].map(lambda todo: any -> any {
                    if todo._jac_id == id {
                        if updated {
                            return updated;
                        }
                        return {"_jac_id": todo._jac_id, "text": todo.text, "done": not todo.done};
                    }
                    return todo;
                });
                setState({
                    "todos": transformed,
                    "inputValue": current["inputValue"],
                    "filter": current["filter"],
                    "loading": False,
                    "error": current["error"]
                });
            } except Exception as err {
                setState({
                    "todos": current["todos"],
                    "inputValue": current["inputValue"],
                    "filter": current["filter"],
                    "loading": current["loading"],
                    "error": err.toString()
                });
            }
        }

        def deleteTodo(id: any) -> None {
            current = state;
            remaining = current["todos"].filter(lambda todo: any -> bool { return todo._jac_id != id; });
            setState({
                "todos": remaining,
                "inputValue": current["inputValue"],
                "filter": current["filter"],
                "loading": current["loading"],
                "error": current["error"]
            });
        }

        def clearCompleted() -> None {
            current = state;
            active = current["todos"].filter(lambda todo: any -> bool { return not todo.done; });
            setState({
                "todos": active,
                "inputValue": current["inputValue"],
                "filter": current["filter"],
                "loading": current["loading"],
                "error": current["error"]
            });
        }

        def setInputValue(value: str) -> None {
            current = state;
            setState({
                "todos": current["todos"],
                "inputValue": value,
                "filter": current["filter"],
                "loading": current["loading"],
                "error": current["error"]
            });
        }

        def setFilter(value: str) -> None {
            current = state;
            setState({
                "todos": current["todos"],
                "inputValue": current["inputValue"],
                "filter": value,
                "loading": current["loading"],
                "error": current["error"]
            });
        }

        def getFilteredTodos() -> list {
            current = state;
            if current["filter"] == "active" {
                return current["todos"].filter(lambda todo: any -> bool { return not todo.done; });
            } elif current["filter"] == "completed" {
                return current["todos"].filter(lambda todo: any -> bool { return todo.done; });
            }
            return current["todos"];
        }

        def getActiveCount() -> int {
            current = state;
            return current["todos"].filter(lambda todo: any -> bool { return not todo.done; }).length;
        }

        def hasCompleted() -> bool {
            current = state;
            return current["todos"].some(lambda todo: any -> bool { return todo.done; });
        }

        def getState() -> dict {
            return state;
        }

        return {
            "state": getState,
            "loadTodos": loadTodos,
            "addTodo": addTodo,
            "toggleTodo": toggleTodo,
            "deleteTodo": deleteTodo,
            "clearCompleted": clearCompleted,
            "setInputValue": setInputValue,
            "setFilter": setFilter,
            "getFilteredTodos": getFilteredTodos,
            "getActiveCount": getActiveCount,
            "hasCompleted": hasCompleted,
            "setLoading": setLoading,
            "setError": setError
        };
    }

    def LoginPage() -> any {
        let [state, setState] = useState({"username": "", "password": "", "loading": False, "error": ""});

        navigate = useNavigate();
        auth = useAuth();

        useEffect(lambda -> None {
            if jacIsLoggedIn() {
                navigate("/dashboard");
            }
        },[]);

        async def handleSubmit(event: any) -> None {
            event.preventDefault();

            current = state;
            setState({
                "username": current["username"],
                "password": current["password"],
                "loading": True,
                "error": ""
            });

            try {
                result = await auth["login"](current["username"], current["password"]);
                if result["success"] {
                    setState({"username": "", "password": "", "loading": False, "error": ""});
                    navigate("/dashboard");
                } else {
                    message = result["error"] if result["error"] else "Unable to login";
                    setState({
                        "username": current["username"],
                        "password": current["password"],
                        "loading": False,
                        "error": message
                    });
                }
            } except Exception as err {
                setState({
                    "username": current["username"],
                    "password": current["password"],
                    "loading": False,
                    "error": err.toString()
                });
            }
        }

        errorBanner = None;
        if state["error"] != "" {
            errorBanner = <div style={{"marginBottom": "16px", "padding": "12px", "borderRadius": "8px", "background": "#fee2e2", "color": "#b91c1c", "fontSize": "14px"}}>{state["error"]}</div>;
        }

        return <div style={{"display": "flex", "justifyContent": "center", "padding": "48px 16px"}}>
            <div style={{"width": "100%", "maxWidth": "420px", "background": "#ffffff", "padding": "32px", "borderRadius": "16px", "boxShadow": "0 10px 30px rgba(15, 23, 42, 0.08)"}}>
                <h1 style={{"margin": "0 0 8px", "fontSize": "28px", "fontWeight": "700", "color": "#1e293b"}}>Welcome back</h1>
                <p style={{"margin": "0 0 24px", "color": "#64748b", "fontSize": "15px"}}>Sign in to keep tracking your todos.</p>
                {errorBanner}
                <form onSubmit={handleSubmit} style={{"display": "flex", "flexDirection": "column", "gap": "16px"}}>
                    <label style={{"display": "flex", "flexDirection": "column", "gap": "8px"}}>
                        <span style={{"fontSize": "14px", "fontWeight": "500", "color": "#475569"}}>Username</span>
                        <input
                            type="text"
                            value={state["username"]}
                            onChange={lambda e: any -> None {
                                current = state;
                                setState({
                                    "username": e.target.value,
                                    "password": current["password"],
                                    "loading": current["loading"],
                                    "error": ""
                                });
                            }}
                            placeholder="Enter your username"
                            style={{"padding": "12px 14px", "borderRadius": "10px", "border": "1px solid #d1d5db", "fontSize": "15px", "outline": "none", "transition": "border 0.2s"}}
                            required={True}
                        />
                    </label>
                    <label style={{"display": "flex", "flexDirection": "column", "gap": "8px"}}>
                        <span style={{"fontSize": "14px", "fontWeight": "500", "color": "#475569"}}>Password</span>
                        <input
                            type="password"
                            value={state["password"]}
                            onChange={lambda e: any -> None {
                                current = state;
                                setState({
                                    "username": current["username"],
                                    "password": e.target.value,
                                    "loading": current["loading"],
                                    "error": ""
                                });
                            }}
                            placeholder="Enter your password"
                            style={{"padding": "12px 14px", "borderRadius": "10px", "border": "1px solid #d1d5db", "fontSize": "15px", "outline": "none", "transition": "border 0.2s"}}
                            required={True}
                        />
                    </label>
                    <button
                        type="submit"
                        disabled={state["loading"]}
                        style={{"padding": "12px", "borderRadius": "10px", "background": "#6366f1", "color": "#ffffff", "fontWeight": "600", "fontSize": "15px", "border": "none", "cursor": "pointer", "opacity": (0.8 if state["loading"] else 1), "transition": "opacity 0.2s"}}
                    >
                        {"Signing in…" if state["loading"] else "Sign in"}
                    </button>
                </form>
                <p style={{"marginTop": "24px", "fontSize": "14px", "color": "#64748b"}}>
                    Need an account? <Link to="/signup" style={{"color": "#3b82f6", "textDecoration": "none", "fontWeight": "600"}}>Create one</Link>
                </p>
            </div>
        </div>;
    }

    def SignupPage() -> any {
        let [state, setState] = useState({"username": "", "password": "", "confirm": "", "loading": False, "error": ""});
        navigate = useNavigate();
        auth = useAuth();

        useEffect(lambda -> None {
            if jacIsLoggedIn() {
                navigate("/dashboard");
            }
        },[]);

        async def handleSubmit(event: any) -> None {
            event.preventDefault();

            current = state;
            setState({
                "username": current["username"],
                "password": current["password"],
                "confirm": current["confirm"],
                "loading": True,
                "error": ""
            });

            try {
                result = await auth["signup"](current["username"], current["password"], current["confirm"]);
                payload = result;
                if result && result["data"] {
                    payload = result["data"];
                }

                success = False;
                message = "";

                if payload && not Array.isArray(payload) {
                    if payload["success"] {
                        success = True;
                    } elif payload["token"] {
                        success = True;
                    }
                    if payload["error"] {
                        message = payload["error"];
                    }
                } else {
                    if payload {
                        success = True;
                    }
                }

                if success {
                    setState({
                        "username": "",
                        "password": "",
                        "confirm": "",
                        "loading": False,
                        "error": ""
                    });
                    navigate("/dashboard");
                    return;
                }

                if message == "" {
                    message = "Unable to create account";
                }
            #    setState((prev)=>{
            #     ...prev,"loading":False
            #    })

                setState({
                    "username": current["username"],
                    "password": current["password"],
                    "confirm": current["confirm"],
                    "loading": False,
                    "error": message
                });
            } except Exception as err {
                setState({
                    "username": current["username"],
                    "password": current["password"],
                    "confirm": current["confirm"],
                    "loading": False,
                    "error": err.toString()
                });
            }
        }

        def handleUsernameChange(event: any) -> None {
            setState({"username": event.target.value, "password": state["password"], "confirm": state["confirm"], "loading": state["loading"], "error": state["error"]});
        }

        def handlePasswordChange(event: any) -> None {
            setState({"username": state["username"], "password": event.target.value, "confirm": state["confirm"], "loading": state["loading"], "error": state["error"]});
        }

        def handleConfirmChange(event: any) -> None {
            setState({"username": state["username"], "password": state["password"], "confirm": event.target.value, "loading": state["loading"], "error": state["error"]});
        }

        error_banner = None;
        if state["error"] != "" {
            error_banner = <div style={{"marginBottom": "16px", "padding": "12px 16px", "borderRadius": "12px", "border": "1px solid #fecaca", "background": "#fee2e2", "color": "#b91c1c"}}>{state["error"]}</div>;
        }

        button_label = "Create account" if not state["loading"] else "Creating…";

        return <div style={{"maxWidth": "420px", "margin": "48px auto", "padding": "32px", "background": "#ffffff", "borderRadius": "16px", "boxShadow": "0 20px 55px rgba(15,23,42,0.12)", "border": "1px solid #e2e8f0"}}>
                <h2 style={{"margin": "0 0 12px", "fontSize": "26px", "color": "#6366f1"}}>Join the network</h2>
                <p style={{"margin": "0 0 20px", "color": "#64748b"}}>Set up your Jac account to start sharing updates.</p>
                {error_banner}
                <form onSubmit={handleSubmit} style={{"display": "grid", "gap": "16px"}}>
                    <label style={{"display": "grid", "gap": "6px"}}>
                        <span style={{"fontSize": "14px", "fontWeight": "600", "color": "#1e293b"}}>Username</span>
                        <input value={state["username"]} onChange={handleUsernameChange} placeholder="Choose a username" style={{"padding": "12px 16px", "borderRadius": "10px", "border": "1px solid #e2e8f0", "fontSize": "16px"}} required={True} />
                    </label>
                    <label style={{"display": "grid", "gap": "6px"}}>
                        <span style={{"fontSize": "14px", "fontWeight": "600", "color": "#1e293b"}}>Password</span>
                        <input type="password" value={state["password"]} onChange={handlePasswordChange} placeholder="Enter a strong password" style={{"padding": "12px 16px", "borderRadius": "10px", "border": "1px solid #e2e8f0", "fontSize": "16px"}} required={True} />
                    </label>
                    <label style={{"display": "grid", "gap": "6px"}}>
                        <span style={{"fontSize": "14px", "fontWeight": "600", "color": "#1e293b"}}>Confirm password</span>
                        <input type="password" value={state["confirm"]} onChange={handleConfirmChange} placeholder="Re-enter your password" style={{"padding": "12px 16px", "borderRadius": "10px", "border": "1px solid #e2e8f0", "fontSize": "16px"}} required={True} />
                    </label>
                    <button type="submit" disabled={state["loading"]} style={{"padding": "12px 16px", "borderRadius": "10px", "border": "1px solid #22c55e", "background": "#22c55e" if not state["loading"] else "#bbf7d0", "color": "#ffffff", "fontWeight": "600", "cursor": "pointer" if not state["loading"] else "not-allowed"}}>{button_label}</button>
                </form>
                <p style={{"marginTop": "16px", "textAlign": "center", "color": "#475569"}}>
                    {"Already have an account? "}
                    <Link to="/login" style={{"marginLeft": "6px", "color": "#6366f1", "textDecoration": "none", "fontWeight": "600"}}>Sign in</Link>
                </p>
            </div>;
    }

    def DashboardPage() -> any {
        todosHook = useTodos();
        useEffect(lambda -> None {
            todosHook["loadTodos"]();
        }, []);
        

        state = todosHook["state"]();
        filteredTodos = todosHook["getFilteredTodos"]();
        activeCount = todosHook["getActiveCount"]();
        
        

        loadingBanner = None;
        if state["loading"] {
            loadingBanner = <div style={{"marginBottom": "16px", "padding": "12px", "borderRadius": "8px", "background": "#e0f2fe", "color": "#075985"}}>Loading todos…</div>;
        }

        errorBanner = None;
        if state["error"] != "" {
            errorBanner = <div style={{"marginBottom": "16px", "padding": "12px", "borderRadius": "8px", "background": "#fee2e2", "color": "#b91c1c"}}>{state["error"]}</div>;
        }

        return <div style={{"maxWidth": "720px", "margin": "0 auto", "padding": "24px"}}>
            <h1 style={{"textAlign": "center", "color": "#1f2937", "marginBottom": "24px", "fontSize": "2.5rem", "fontWeight": "700"}}>📝 My Todo App</h1>
            {loadingBanner}
            {errorBanner}
            <div style={{"display": "flex", "gap": "8px", "marginBottom": "24px", "background": "#ffffff", "padding": "16px", "borderRadius": "12px", "boxShadow": "0 1px 3px rgba(0,0,0,0.1)"}}>
                <input
                    type="text"
                    value={state["inputValue"]}
                    onChange={lambda e: any -> None { todosHook["setInputValue"](e.target.value); }}
                    onKeyPress={lambda e: any -> None {
                        if e.key == "Enter" { todosHook["addTodo"](); }
                    }}
                    placeholder="What needs to be done?"
                    style={{"flex": "1", "padding": "12px 16px", "border": "1px solid #e5e7eb", "borderRadius": "8px", "fontSize": "16px", "outline": "none"}}
                />
                <button
                    onClick={todosHook["addTodo"]}
                    style={{"padding": "12px 24px", "background": "#3b82f6", "color": "#ffffff", "border": "none", "borderRadius": "8px", "fontSize": "16px", "fontWeight": "600", "cursor": "pointer", "transition": "background 0.2s"}}
                >
                    Add
                </button>
            </div>

            <div style={{"display": "flex", "gap": "8px", "marginBottom": "24px", "justifyContent": "center"}}>
                <button
                    onClick={lambda -> None { todosHook["setFilter"]("all"); }}
                    style={{"padding": "8px 16px", "background": ("#3b82f6" if state["filter"] == "all" else "#ffffff"), "color": ("#ffffff" if state["filter"] == "all" else "#3b82f6"), "border": "1px solid #3b82f6", "borderRadius": "6px", "fontSize": "14px", "fontWeight": "600", "cursor": "pointer"}}
                >
                    All
                </button>
                <button
                    onClick={lambda -> None { todosHook["setFilter"]("active"); }}
                    style={{"padding": "8px 16px", "background": ("#3b82f6" if state["filter"] == "active" else "#ffffff"), "color": ("#ffffff" if state["filter"] == "active" else "#3b82f6"), "border": "1px solid #3b82f6", "borderRadius": "6px", "fontSize": "14px", "fontWeight": "600", "cursor": "pointer"}}
                >
                    Active
                </button>
                <button
                    onClick={lambda -> None { todosHook["setFilter"]("completed"); }}
                    style={{"padding": "8px 16px", "background": ("#3b82f6" if state["filter"] == "completed" else "#ffffff"), "color": ("#ffffff" if state["filter"] == "completed" else "#3b82f6"), "border": "1px solid #3b82f6", "borderRadius": "6px", "fontSize": "14px", "fontWeight": "600", "cursor": "pointer"}}
                >
                    Completed
                </button>
            </div>

            <div style={{"background": "#ffffff", "borderRadius": "12px", "boxShadow": "0 1px 3px rgba(0,0,0,0.1)", "overflow": "hidden"}}>
                {( <div style={{"padding": "40px", "textAlign": "center", "color": "#9ca3af"}}>{("No todos yet. Add one above!" if state["filter"] == "all" else ("No active todos!" if state["filter"] == "active" else "No completed todos!"))}</div>) if filteredTodos.length == 0 else (
                    filteredTodos.map(lambda todo: any -> any {
                        return <div key={todo._jac_id} style={{"display": "flex", "alignItems": "center", "gap": "12px", "padding": "16px", "borderBottom": "1px solid #e5e7eb", "transition": "background 0.2s"}}>
                            <input
                                type="checkbox"
                                checked={todo.done}
                                onChange={lambda -> None { todosHook["toggleTodo"](todo._jac_id); }}
                                style={{"width": "20px", "height": "20px", "cursor": "pointer"}}
                            />
                            <span style={{"flex": "1", "textDecoration": ("line-through" if todo.done else "none"), "color": ("#9ca3af" if todo.done else "#1f2937"), "fontSize": "16px"}}>{todo.text}</span>
                            <button
                                onClick={lambda -> None { todosHook["deleteTodo"](todo._jac_id); }}
                                style={{"padding": "6px 12px", "background": "#ef4444", "color": "#ffffff", "border": "none", "borderRadius": "6px", "fontSize": "14px", "fontWeight": "500", "cursor": "pointer", "transition": "background 0.2s"}}
                            >
                                Delete
                            </button>
                        </div>;
                    })
                )}
            </div>

            {( <div style={{"display": "flex", "justifyContent": "space-between", "alignItems": "center", "marginTop": "24px", "padding": "16px", "background": "#ffffff", "borderRadius": "12px", "boxShadow": "0 1px 3px rgba(0,0,0,0.1)"}}>
                <span style={{"color": "#6b7280", "fontSize": "14px"}}>{activeCount} {"item" if activeCount == 1 else "items"} left</span>
                {( <button onClick={todosHook["clearCompleted"]} style={{"padding": "8px 16px", "background": "#ef4444", "color": "#ffffff", "border": "none", "borderRadius": "6px", "fontSize": "14px", "fontWeight": "600", "cursor": "pointer"}}>Clear Completed</button>) if todosHook["hasCompleted"]() else <span></span>}
            </div>) if state["todos"].length > 0 else <span></span>}
        </div>;
    }

   

    def AppHeader() -> any {
        navigate = useNavigate();
        auth = useAuth();
        is_authed = jacIsLoggedIn();

        def handleLogout(event: any) -> None {
            event.preventDefault();
            auth["logout"]();
            navigate("/login");
        }

        auth_cta = <Link to="/login" style={{"padding": "8px 14px", "borderRadius": "8px", "border": "1px solid #6366f1", "color": "#6366f1", "textDecoration": "none", "fontWeight": "600"}}>Sign in</Link>;
        if is_authed {
            auth_cta = <button onClick={handleLogout} style={{"padding": "8px 14px", "borderRadius": "8px", "border": "1px solid #ef4444", "background": "#fef2f2", "color": "#b91c1c", "cursor": "pointer"}}>Sign out</button>;
        }

        dashboard_link = None;
        if is_authed {
            dashboard_link = <Link to="/dashboard" style={{"color": "#0f172a", "textDecoration": "none", "fontWeight": "600"}}>Dashboard</Link>;
        }

        return <header style={{"background": "#ffffff", "borderBottom": "1px solid #e2e8f0", "padding": "12px 24px"}}>
            <div style={{"maxWidth": "1080px", "margin": "0 auto", "display": "flex", "alignItems": "center", "gap": "16px", "justifyContent": "space-between", "flexWrap": "wrap"}}>
                <div style={{"display": "flex", "alignItems": "center", "gap": "16px"}}>
                    <nav style={{"display": "flex", "gap": "12px", "alignItems": "center"}}>
                        <Link to="/" style={{"color": "#475569", "textDecoration": "none"}}>Home</Link>
                        <Link to="/login" style={{"color": "#475569", "textDecoration": "none"}}>Login</Link>
                        <Link to="/signup" style={{"color": "#475569", "textDecoration": "none"}}>Sign up</Link>
                        {dashboard_link}
                    </nav>
                </div>
                {auth_cta}
            </div>
        </header>;
    }

    def app() -> any {

        return <Router defaultRoute="/login">
                <div style={{"minHeight": "95vh", "font-family":"sans-serif", "transition": "background 0.3s ease", "background": "#f1f5f9"}}>
                    <AppHeader />
                    <main style={{"maxWidth": "1080px", "margin": "0 auto", "width": "100%", "padding": "32px 16px"}}>
                        <Routes>
                            <Route path="/login" component={LoginPage} />
                            <Route path="/signup" component={SignupPage} />
                            <Route path="/dashboard" component={DashboardPage} guard={jacIsLoggedIn} />
                        </Routes>
                    </main>
                </div>
            </Router>;
    }
}
