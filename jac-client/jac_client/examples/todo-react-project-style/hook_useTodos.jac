cl def useTodos() -> dict {
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
            todo = result._jac_id ? result : result.reports[0] if result.reports and len(result.reports) > 0 else None;
            if todo {
                state = todos();
                setTodos({"items": state.items.concat([{"id": todo._jac_id, "text": todo.text, "done": todo.done}])});
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
