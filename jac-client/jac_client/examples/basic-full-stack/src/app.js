import {__jacJsx} from "@jac-client/utils";
import { useState, useEffect } from "react";
import { __jacSpawn } from "@jac-client/utils";
function app() {
  let [todos, setTodos] = useState([]);
  let [inputValue, setInputValue] = useState("");
  let [filter, setFilter] = useState("all");
  useEffect(() => {
    async function loadTodos() {
      todos = await __jacSpawn("read_todos");
      console.log(todos);
      setTodos(todos.reports);
    }
    loadTodos();
  }, []);
  async function addTodo() {
    if (!inputValue.trim()) {
      return;
    }
    let newTodo = {"id": Date.now(), "text": inputValue.trim(), "done": false};
    await __jacSpawn("create_todo", {"text": inputValue.trim()});
    let newTodos = todos.concat([newTodo]);
    setTodos(newTodos);
    setInputValue("");
  }
  function toggleTodo(id) {
    setTodos(todos.map(todo => {
      if (todo.id === id) {
        let updatedTodo = {"id": todo.id, "text": todo.text, "done": !todo.done};
        return updatedTodo;
      }
      return todo;
    }));
  }
  function deleteTodo(id) {
    setTodos(todos.filter(todo => {
      return todo.id !== id;
    }));
  }
  function clearCompleted() {
    setTodos(todos.filter(todo => {
      return !todo.done;
    }));
  }
  function getFilteredTodos() {
    if (filter === "active") {
      return todos.filter(todo => {
        return !todo.done;
      });
    } else if (filter === "completed") {
      return todos.filter(todo => {
        return todo.done;
      });
    }
    return todos;
  }
  let activeCount = todos.filter(todo => {
    return !todo.done;
  }).length;
  let filteredTodos = getFilteredTodos();
  return __jacJsx("div", {"style": {"maxWidth": "600px", "margin": "40px auto", "padding": "24px", "fontFamily": "system-ui, -apple-system, sans-serif", "background": "#f9fafb", "minHeight": "100vh"}}, [__jacJsx("h1", {"style": {"textAlign": "center", "color": "#1f2937", "marginBottom": "32px", "fontSize": "2.5rem", "fontWeight": "700"}}, ["📝 My Todo App"]), __jacJsx("div", {"style": {"display": "flex", "gap": "8px", "marginBottom": "24px", "background": "#ffffff", "padding": "16px", "borderRadius": "12px", "boxShadow": "0 1px 3px rgba(0,0,0,0.1)"}}, [__jacJsx("input", {"type": "text", "value": inputValue, "onChange": e => {
    setInputValue(e.target.value);
  }, "onKeyPress": e => {
    if (e.key === "Enter") {
      addTodo();
    }
  }, "placeholder": "What needs to be done?", "style": {"flex": "1", "padding": "12px 16px", "border": "1px solid #e5e7eb", "borderRadius": "8px", "fontSize": "16px", "outline": "none"}}, []), __jacJsx("button", {"onClick": addTodo, "style": {"padding": "12px 24px", "background": "#3b82f6", "color": "#ffffff", "border": "none", "borderRadius": "8px", "fontSize": "16px", "fontWeight": "600", "cursor": "pointer", "transition": "background 0.2s"}}, ["Add"])]), __jacJsx("div", {"style": {"display": "flex", "gap": "8px", "marginBottom": "24px", "justifyContent": "center"}}, [__jacJsx("button", {"onClick": () => {
    setFilter("all");
  }, "style": {"padding": "8px 16px", "background": filter === "all" ? "#3b82f6" : "#ffffff", "color": filter === "all" ? "#ffffff" : "#3b82f6", "border": "1px solid #3b82f6", "borderRadius": "6px", "fontSize": "14px", "fontWeight": "600", "cursor": "pointer"}}, ["All"]), __jacJsx("button", {"onClick": () => {
    setFilter("active");
  }, "style": {"padding": "8px 16px", "background": filter === "active" ? "#3b82f6" : "#ffffff", "color": filter === "active" ? "#ffffff" : "#3b82f6", "border": "1px solid #3b82f6", "borderRadius": "6px", "fontSize": "14px", "fontWeight": "600", "cursor": "pointer"}}, ["Active"]), __jacJsx("button", {"onClick": () => {
    setFilter("completed");
  }, "style": {"padding": "8px 16px", "background": filter === "completed" ? "#3b82f6" : "#ffffff", "color": filter === "completed" ? "#ffffff" : "#3b82f6", "border": "1px solid #3b82f6", "borderRadius": "6px", "fontSize": "14px", "fontWeight": "600", "cursor": "pointer"}}, ["Completed"])]), __jacJsx("div", {"style": {"background": "#ffffff", "borderRadius": "12px", "boxShadow": "0 1px 3px rgba(0,0,0,0.1)", "overflow": "hidden"}}, [filteredTodos.length === 0 ? __jacJsx("div", {"style": {"padding": "40px", "textAlign": "center", "color": "#9ca3af"}}, [filter === "all" ? "No todos yet. Add one above!" : filter === "active" ? "No active todos!" : "No completed todos!"]) : filteredTodos.map(todo => {
    return __jacJsx("div", {"key": todo.id, "style": {"display": "flex", "alignItems": "center", "gap": "12px", "padding": "16px", "borderBottom": "1px solid #e5e7eb", "transition": "background 0.2s"}}, [__jacJsx("input", {"type": "checkbox", "checked": todo.done, "onChange": () => {
      toggleTodo(todo.id);
    }, "style": {"width": "20px", "height": "20px", "cursor": "pointer"}}, []), __jacJsx("span", {"style": {"flex": "1", "textDecoration": todo.done ? "line-through" : "none", "color": todo.done ? "#9ca3af" : "#1f2937", "fontSize": "16px"}}, [todo.text]), __jacJsx("button", {"onClick": () => {
      deleteTodo(todo.id);
    }, "style": {"padding": "6px 12px", "background": "#ef4444", "color": "#ffffff", "border": "none", "borderRadius": "6px", "fontSize": "14px", "fontWeight": "500", "cursor": "pointer", "transition": "background 0.2s"}}, ["Delete"])]);
  })]), todos.length > 0 ? __jacJsx("div", {"style": {"display": "flex", "justifyContent": "space-between", "alignItems": "center", "marginTop": "24px", "padding": "16px", "background": "#ffffff", "borderRadius": "12px", "boxShadow": "0 1px 3px rgba(0,0,0,0.1)"}}, [__jacJsx("span", {"style": {"color": "#6b7280", "fontSize": "14px"}}, [activeCount, " ", activeCount === 1 ? "item" : "items", " left"]), todos.some(todo => {
    return todo.done;
  }) ? __jacJsx("button", {"onClick": clearCompleted, "style": {"padding": "8px 16px", "background": "#ef4444", "color": "#ffffff", "border": "none", "borderRadius": "6px", "fontSize": "14px", "fontWeight": "600", "cursor": "pointer"}}, ["Clear Completed"]) : null]) : null]);
}
export { app };
