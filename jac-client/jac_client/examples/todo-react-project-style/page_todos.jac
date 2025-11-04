cl import from .hook_useTodos { useTodos }
cl import from .hook_useAuth { useAuth }
cl import from .component_card { Card }
cl import from .component_button { Button }
cl import from .component_todoForm { TodoForm }
cl import from .component_todoList { TodoList }

cl def TodosPage() -> any {
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
                    {len(state.items)} {len(state.items) == 1 ? "todo" : "todos"}
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

            {state.error ? <div style={{"padding": "12px", "background": "#fee2e2", "color": "#dc2626", "borderRadius": "6px", "marginBottom": "16px"}}>{state.error}</div> : None}

            <TodoForm onSubmit={todosHook["addTodo"]} />

            {state.loading ? <div style={{"textAlign": "center", "padding": "40px", "color": "#9ca3af"}}>Loading...</div> : None}

            {not state.loading ? <TodoList
                items={state.items}
                onToggle={todosHook["toggleTodo"]}
                onDelete={todosHook["deleteTodo"]}
            /> : None}
        </Card>
    </div>;
}
