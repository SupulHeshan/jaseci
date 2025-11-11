import {__jacJsx} from "@jac-client/utils";
import { useState, useEffect, useMemo, useContext, useRef } from "react";
import { Router, Routes, Route, Link, Navigate, useNavigate, jacIsLoggedIn, jacLogin, jacSignup, __jacSpawn, jacLogout } from "@jac-client/utils";
function useAuth() {
  async function login(username, password) {
    try {
      let result = await jacLogin(username, password);
      if (result) {
        return {"success": true, "data": result, "error": null};
      }
      return {"success": false, "error": "Invalid credentials"};
    } catch {
      return {"success": false, "error": "Invalid credentials"};
    }
  }
  async function signup(username, password, confirmPassword) {
    if (password !== confirmPassword) {
      return {"success": false, "error": "Passwords do not match"};
    }
    try {
      let result = await jacSignup(username, password);
      let success = false;
      let message = "";
      if (result && !Array.isArray(result)) {
        if (result["success"]) {
          success = true;
        } else if (result["token"]) {
          success = true;
        }
        if (result["error"]) {
          message = result["error"];
        }
      } else {
        if (result) {
          success = true;
        }
      }
      if (success) {
        return {"success": true, "data": result, "error": null};
      }
      let fallback = message !== "" ? message : "Unable to create account";
      return {"success": false, "error": fallback};
    } catch (err) {
      return {"success": false, "error": err.toString()};
    }
  }
  function logout() {
    jacLogout();
  }
  function isAuthenticated() {
    return jacIsLoggedIn();
  }
  return {"login": login, "signup": signup, "logout": logout, "isAuthenticated": isAuthenticated};
}
function useTodos() {
  let [state, setState] = useState({"todos": [], "inputValue": "", "filter": "all", "loading": false, "error": ""});
  function flattenReports(raw) {
    if (!raw) {
      return [];
    }
    if (Array.isArray(raw)) {
      let accumulator = [];
      raw.forEach(entry => {
        if (Array.isArray(entry)) {
          entry.forEach(nested => {
            if (nested) {
              accumulator.push(nested);
            }
          });
        } else if (entry) {
          accumulator.push(entry);
        }
      });
      return accumulator;
    }
    return [raw];
  }
  function setLoading(loading) {
    let current = state;
    let nextState = {"todos": current["todos"], "inputValue": current["inputValue"], "filter": current["filter"], "loading": loading, "error": current["error"]};
    setState(nextState);
  }
  function setError(message) {
    let current = state;
    let nextState = {"todos": current["todos"], "inputValue": current["inputValue"], "filter": current["filter"], "loading": current["loading"], "error": message};
    setState(nextState);
  }
  async function loadTodos() {
    let current = state;
    setState({"todos": current["todos"], "inputValue": current["inputValue"], "filter": current["filter"], "loading": true, "error": current["error"]});
    try {
      let response = await __jacSpawn("read_todos", "", {});
      let items = flattenReports(response.reports);
      setState({"todos": items, "inputValue": current["inputValue"], "filter": current["filter"], "loading": false, "error": ""});
    } catch (err) {
      setState({"todos": current["todos"], "inputValue": current["inputValue"], "filter": current["filter"], "loading": false, "error": err.toString()});
    }
  }
  async function addTodo() {
    let current = state;
    let text = current["inputValue"].trim();
    if (!text) {
      return;
    }
    try {
      let result = await __jacSpawn("create_todo", "", {"text": text});
      let reportItems = flattenReports(result.reports);
      let created = null;
      if (reportItems.length > 0) {
        created = reportItems[0];
      }
      if (created) {
        let updatedTodos = current["todos"].concat([created]);
        setState({"todos": updatedTodos, "inputValue": "", "filter": current["filter"], "loading": false, "error": ""});
      } else {
        await loadTodos();
      }
    } catch (err) {
      setState({"todos": current["todos"], "inputValue": current["inputValue"], "filter": current["filter"], "loading": false, "error": err.toString()});
    }
  }
  async function toggleTodo(id) {
    let current = state;
    try {
      let result = await __jacSpawn("toggle_todo", id, {});
      let reportItems = flattenReports(result.reports);
      let updated = null;
      if (reportItems.length > 0) {
        updated = reportItems[0];
      }
      let transformed = current["todos"].map(todo => {
        if (todo._jac_id === id) {
          if (updated) {
            return updated;
          }
          return {"_jac_id": todo._jac_id, "text": todo.text, "done": !todo.done};
        }
        return todo;
      });
      setState({"todos": transformed, "inputValue": current["inputValue"], "filter": current["filter"], "loading": false, "error": current["error"]});
    } catch (err) {
      setState({"todos": current["todos"], "inputValue": current["inputValue"], "filter": current["filter"], "loading": current["loading"], "error": err.toString()});
    }
  }
  function deleteTodo(id) {
    let current = state;
    let remaining = current["todos"].filter(todo => {
      return todo._jac_id !== id;
    });
    setState({"todos": remaining, "inputValue": current["inputValue"], "filter": current["filter"], "loading": current["loading"], "error": current["error"]});
  }
  function clearCompleted() {
    let current = state;
    let active = current["todos"].filter(todo => {
      return !todo.done;
    });
    setState({"todos": active, "inputValue": current["inputValue"], "filter": current["filter"], "loading": current["loading"], "error": current["error"]});
  }
  function setInputValue(value) {
    let current = state;
    setState({"todos": current["todos"], "inputValue": value, "filter": current["filter"], "loading": current["loading"], "error": current["error"]});
  }
  function setFilter(value) {
    let current = state;
    setState({"todos": current["todos"], "inputValue": current["inputValue"], "filter": value, "loading": current["loading"], "error": current["error"]});
  }
  function getFilteredTodos() {
    let current = state;
    if (current["filter"] === "active") {
      return current["todos"].filter(todo => {
        return !todo.done;
      });
    } else if (current["filter"] === "completed") {
      return current["todos"].filter(todo => {
        return todo.done;
      });
    }
    return current["todos"];
  }
  function getActiveCount() {
    let current = state;
    return current["todos"].filter(todo => {
      return !todo.done;
    }).length;
  }
  function hasCompleted() {
    let current = state;
    return current["todos"].some(todo => {
      return todo.done;
    });
  }
  function getState() {
    return state;
  }
  return {"state": getState, "loadTodos": loadTodos, "addTodo": addTodo, "toggleTodo": toggleTodo, "deleteTodo": deleteTodo, "clearCompleted": clearCompleted, "setInputValue": setInputValue, "setFilter": setFilter, "getFilteredTodos": getFilteredTodos, "getActiveCount": getActiveCount, "hasCompleted": hasCompleted, "setLoading": setLoading, "setError": setError};
}
function LoginPage() {
  let [state, setState] = useState({"username": "", "password": "", "loading": false, "error": ""});
  let navigate = useNavigate();
  let auth = useAuth();
  useEffect(() => {
    if (jacIsLoggedIn()) {
      navigate("/dashboard");
    }
  }, []);
  async function handleSubmit(event) {
    event.preventDefault();
    let current = state;
    setState({"username": current["username"], "password": current["password"], "loading": true, "error": ""});
    try {
      let result = await auth["login"](current["username"], current["password"]);
      if (result["success"]) {
        setState({"username": "", "password": "", "loading": false, "error": ""});
        navigate("/dashboard");
      } else {
        let message = result["error"] ? result["error"] : "Unable to login";
        setState({"username": current["username"], "password": current["password"], "loading": false, "error": message});
      }
    } catch (err) {
      setState({"username": current["username"], "password": current["password"], "loading": false, "error": err.toString()});
    }
  }
  let errorBanner = null;
  if (state["error"] !== "") {
    errorBanner = __jacJsx("div", {"style": {"marginBottom": "16px", "padding": "12px", "borderRadius": "8px", "background": "#fee2e2", "color": "#b91c1c", "fontSize": "14px"}}, [state["error"]]);
  }
  return __jacJsx("div", {"style": {"display": "flex", "justifyContent": "center", "padding": "48px 16px"}}, [__jacJsx("div", {"style": {"width": "100%", "maxWidth": "420px", "background": "#ffffff", "padding": "32px", "borderRadius": "16px", "boxShadow": "0 10px 30px rgba(15, 23, 42, 0.08)"}}, [__jacJsx("h1", {"style": {"margin": "0 0 8px", "fontSize": "28px", "fontWeight": "700", "color": "#1e293b"}}, ["Welcome back"]), __jacJsx("p", {"style": {"margin": "0 0 24px", "color": "#64748b", "fontSize": "15px"}}, ["Sign in to keep tracking your todos."]), errorBanner, __jacJsx("form", {"onSubmit": handleSubmit, "style": {"display": "flex", "flexDirection": "column", "gap": "16px"}}, [__jacJsx("label", {"style": {"display": "flex", "flexDirection": "column", "gap": "8px"}}, [__jacJsx("span", {"style": {"fontSize": "14px", "fontWeight": "500", "color": "#475569"}}, ["Username"]), __jacJsx("input", {"type": "text", "value": state["username"], "onChange": e => {
    let current = state;
    setState({"username": e.target.value, "password": current["password"], "loading": current["loading"], "error": ""});
  }, "placeholder": "Enter your username", "style": {"padding": "12px 14px", "borderRadius": "10px", "border": "1px solid #d1d5db", "fontSize": "15px", "outline": "none", "transition": "border 0.2s"}, "required": true}, [])]), __jacJsx("label", {"style": {"display": "flex", "flexDirection": "column", "gap": "8px"}}, [__jacJsx("span", {"style": {"fontSize": "14px", "fontWeight": "500", "color": "#475569"}}, ["Password"]), __jacJsx("input", {"type": "password", "value": state["password"], "onChange": e => {
    let current = state;
    setState({"username": current["username"], "password": e.target.value, "loading": current["loading"], "error": ""});
  }, "placeholder": "Enter your password", "style": {"padding": "12px 14px", "borderRadius": "10px", "border": "1px solid #d1d5db", "fontSize": "15px", "outline": "none", "transition": "border 0.2s"}, "required": true}, [])]), __jacJsx("button", {"type": "submit", "disabled": state["loading"], "style": {"padding": "12px", "borderRadius": "10px", "background": "#6366f1", "color": "#ffffff", "fontWeight": "600", "fontSize": "15px", "border": "none", "cursor": "pointer", "opacity": state["loading"] ? 0.8 : 1, "transition": "opacity 0.2s"}}, [state["loading"] ? "Signing in\u2026" : "Sign in"])]), __jacJsx("p", {"style": {"marginTop": "24px", "fontSize": "14px", "color": "#64748b"}}, ["Need an account? ", __jacJsx(Link, {"to": "/signup", "style": {"color": "#3b82f6", "textDecoration": "none", "fontWeight": "600"}}, ["Create one"])])])]);
}
function SignupPage() {
  let [state, setState] = useState({"username": "", "password": "", "confirm": "", "loading": false, "error": ""});
  let navigate = useNavigate();
  let auth = useAuth();
  useEffect(() => {
    if (jacIsLoggedIn()) {
      navigate("/dashboard");
    }
  }, []);
  async function handleSubmit(event) {
    event.preventDefault();
    let current = state;
    setState({"username": current["username"], "password": current["password"], "confirm": current["confirm"], "loading": true, "error": ""});
    try {
      let result = await auth["signup"](current["username"], current["password"], current["confirm"]);
      let payload = result;
      if (result && result["data"]) {
        payload = result["data"];
      }
      let success = false;
      let message = "";
      if (payload && !Array.isArray(payload)) {
        if (payload["success"]) {
          success = true;
        } else if (payload["token"]) {
          success = true;
        }
        if (payload["error"]) {
          message = payload["error"];
        }
      } else {
        if (payload) {
          success = true;
        }
      }
      if (success) {
        setState({"username": "", "password": "", "confirm": "", "loading": false, "error": ""});
        navigate("/dashboard");
        return;
      }
      if (message === "") {
        message = "Unable to create account";
      }
      setState({"username": current["username"], "password": current["password"], "confirm": current["confirm"], "loading": false, "error": message});
    } catch (err) {
      setState({"username": current["username"], "password": current["password"], "confirm": current["confirm"], "loading": false, "error": err.toString()});
    }
  }
  function handleUsernameChange(event) {
    setState({"username": event.target.value, "password": state["password"], "confirm": state["confirm"], "loading": state["loading"], "error": state["error"]});
  }
  function handlePasswordChange(event) {
    setState({"username": state["username"], "password": event.target.value, "confirm": state["confirm"], "loading": state["loading"], "error": state["error"]});
  }
  function handleConfirmChange(event) {
    setState({"username": state["username"], "password": state["password"], "confirm": event.target.value, "loading": state["loading"], "error": state["error"]});
  }
  let error_banner = null;
  if (state["error"] !== "") {
    error_banner = __jacJsx("div", {"style": {"marginBottom": "16px", "padding": "12px 16px", "borderRadius": "12px", "border": "1px solid #fecaca", "background": "#fee2e2", "color": "#b91c1c"}}, [state["error"]]);
  }
  let button_label = !state["loading"] ? "Create account" : "Creating\u2026";
  return __jacJsx("div", {"style": {"maxWidth": "420px", "margin": "48px auto", "padding": "32px", "background": "#ffffff", "borderRadius": "16px", "boxShadow": "0 20px 55px rgba(15,23,42,0.12)", "border": "1px solid #e2e8f0"}}, [__jacJsx("h2", {"style": {"margin": "0 0 12px", "fontSize": "26px", "color": "#6366f1"}}, ["Join the network"]), __jacJsx("p", {"style": {"margin": "0 0 20px", "color": "#64748b"}}, ["Set up your Jac account to start sharing updates."]), error_banner, __jacJsx("form", {"onSubmit": handleSubmit, "style": {"display": "grid", "gap": "16px"}}, [__jacJsx("label", {"style": {"display": "grid", "gap": "6px"}}, [__jacJsx("span", {"style": {"fontSize": "14px", "fontWeight": "600", "color": "#1e293b"}}, ["Username"]), __jacJsx("input", {"value": state["username"], "onChange": handleUsernameChange, "placeholder": "Choose a username", "style": {"padding": "12px 16px", "borderRadius": "10px", "border": "1px solid #e2e8f0", "fontSize": "16px"}, "required": true}, [])]), __jacJsx("label", {"style": {"display": "grid", "gap": "6px"}}, [__jacJsx("span", {"style": {"fontSize": "14px", "fontWeight": "600", "color": "#1e293b"}}, ["Password"]), __jacJsx("input", {"type": "password", "value": state["password"], "onChange": handlePasswordChange, "placeholder": "Enter a strong password", "style": {"padding": "12px 16px", "borderRadius": "10px", "border": "1px solid #e2e8f0", "fontSize": "16px"}, "required": true}, [])]), __jacJsx("label", {"style": {"display": "grid", "gap": "6px"}}, [__jacJsx("span", {"style": {"fontSize": "14px", "fontWeight": "600", "color": "#1e293b"}}, ["Confirm password"]), __jacJsx("input", {"type": "password", "value": state["confirm"], "onChange": handleConfirmChange, "placeholder": "Re-enter your password", "style": {"padding": "12px 16px", "borderRadius": "10px", "border": "1px solid #e2e8f0", "fontSize": "16px"}, "required": true}, [])]), __jacJsx("button", {"type": "submit", "disabled": state["loading"], "style": {"padding": "12px 16px", "borderRadius": "10px", "border": "1px solid #22c55e", "background": !state["loading"] ? "#22c55e" : "#bbf7d0", "color": "#ffffff", "fontWeight": "600", "cursor": !state["loading"] ? "pointer" : "not-allowed"}}, [button_label])]), __jacJsx("p", {"style": {"marginTop": "16px", "textAlign": "center", "color": "#475569"}}, ["Already have an account? ", __jacJsx(Link, {"to": "/login", "style": {"marginLeft": "6px", "color": "#6366f1", "textDecoration": "none", "fontWeight": "600"}}, ["Sign in"])])]);
}
function DashboardPage() {
  let todosHook = useTodos();
  useEffect(() => {
    todosHook["loadTodos"]();
  }, []);
  let state = todosHook["state"]();
  let filteredTodos = todosHook["getFilteredTodos"]();
  let activeCount = todosHook["getActiveCount"]();
  let loadingBanner = null;
  if (state["loading"]) {
    loadingBanner = __jacJsx("div", {"style": {"marginBottom": "16px", "padding": "12px", "borderRadius": "8px", "background": "#e0f2fe", "color": "#075985"}}, ["Loading todos…"]);
  }
  let errorBanner = null;
  if (state["error"] !== "") {
    errorBanner = __jacJsx("div", {"style": {"marginBottom": "16px", "padding": "12px", "borderRadius": "8px", "background": "#fee2e2", "color": "#b91c1c"}}, [state["error"]]);
  }
  return __jacJsx("div", {"style": {"maxWidth": "720px", "margin": "0 auto", "padding": "24px"}}, [__jacJsx("h1", {"style": {"textAlign": "center", "color": "#1f2937", "marginBottom": "24px", "fontSize": "2.5rem", "fontWeight": "700"}}, ["📝 My Todo App"]), loadingBanner, errorBanner, __jacJsx("div", {"style": {"display": "flex", "gap": "8px", "marginBottom": "24px", "background": "#ffffff", "padding": "16px", "borderRadius": "12px", "boxShadow": "0 1px 3px rgba(0,0,0,0.1)"}}, [__jacJsx("input", {"type": "text", "value": state["inputValue"], "onChange": e => {
    todosHook["setInputValue"](e.target.value);
  }, "onKeyPress": e => {
    if (e.key === "Enter") {
      todosHook["addTodo"]();
    }
  }, "placeholder": "What needs to be done?", "style": {"flex": "1", "padding": "12px 16px", "border": "1px solid #e5e7eb", "borderRadius": "8px", "fontSize": "16px", "outline": "none"}}, []), __jacJsx("button", {"onClick": todosHook["addTodo"], "style": {"padding": "12px 24px", "background": "#3b82f6", "color": "#ffffff", "border": "none", "borderRadius": "8px", "fontSize": "16px", "fontWeight": "600", "cursor": "pointer", "transition": "background 0.2s"}}, ["Add"])]), __jacJsx("div", {"style": {"display": "flex", "gap": "8px", "marginBottom": "24px", "justifyContent": "center"}}, [__jacJsx("button", {"onClick": () => {
    todosHook["setFilter"]("all");
  }, "style": {"padding": "8px 16px", "background": state["filter"] === "all" ? "#3b82f6" : "#ffffff", "color": state["filter"] === "all" ? "#ffffff" : "#3b82f6", "border": "1px solid #3b82f6", "borderRadius": "6px", "fontSize": "14px", "fontWeight": "600", "cursor": "pointer"}}, ["All"]), __jacJsx("button", {"onClick": () => {
    todosHook["setFilter"]("active");
  }, "style": {"padding": "8px 16px", "background": state["filter"] === "active" ? "#3b82f6" : "#ffffff", "color": state["filter"] === "active" ? "#ffffff" : "#3b82f6", "border": "1px solid #3b82f6", "borderRadius": "6px", "fontSize": "14px", "fontWeight": "600", "cursor": "pointer"}}, ["Active"]), __jacJsx("button", {"onClick": () => {
    todosHook["setFilter"]("completed");
  }, "style": {"padding": "8px 16px", "background": state["filter"] === "completed" ? "#3b82f6" : "#ffffff", "color": state["filter"] === "completed" ? "#ffffff" : "#3b82f6", "border": "1px solid #3b82f6", "borderRadius": "6px", "fontSize": "14px", "fontWeight": "600", "cursor": "pointer"}}, ["Completed"])]), __jacJsx("div", {"style": {"background": "#ffffff", "borderRadius": "12px", "boxShadow": "0 1px 3px rgba(0,0,0,0.1)", "overflow": "hidden"}}, [filteredTodos.length === 0 ? __jacJsx("div", {"style": {"padding": "40px", "textAlign": "center", "color": "#9ca3af"}}, [state["filter"] === "all" ? "No todos yet. Add one above!" : state["filter"] === "active" ? "No active todos!" : "No completed todos!"]) : filteredTodos.map(todo => {
    return __jacJsx("div", {"key": todo._jac_id, "style": {"display": "flex", "alignItems": "center", "gap": "12px", "padding": "16px", "borderBottom": "1px solid #e5e7eb", "transition": "background 0.2s"}}, [__jacJsx("input", {"type": "checkbox", "checked": todo.done, "onChange": () => {
      todosHook["toggleTodo"](todo._jac_id);
    }, "style": {"width": "20px", "height": "20px", "cursor": "pointer"}}, []), __jacJsx("span", {"style": {"flex": "1", "textDecoration": todo.done ? "line-through" : "none", "color": todo.done ? "#9ca3af" : "#1f2937", "fontSize": "16px"}}, [todo.text]), __jacJsx("button", {"onClick": () => {
      todosHook["deleteTodo"](todo._jac_id);
    }, "style": {"padding": "6px 12px", "background": "#ef4444", "color": "#ffffff", "border": "none", "borderRadius": "6px", "fontSize": "14px", "fontWeight": "500", "cursor": "pointer", "transition": "background 0.2s"}}, ["Delete"])]);
  })]), state["todos"].length > 0 ? __jacJsx("div", {"style": {"display": "flex", "justifyContent": "space-between", "alignItems": "center", "marginTop": "24px", "padding": "16px", "background": "#ffffff", "borderRadius": "12px", "boxShadow": "0 1px 3px rgba(0,0,0,0.1)"}}, [__jacJsx("span", {"style": {"color": "#6b7280", "fontSize": "14px"}}, [activeCount, " ", activeCount === 1 ? "item" : "items", " left"]), todosHook["hasCompleted"]() ? __jacJsx("button", {"onClick": todosHook["clearCompleted"], "style": {"padding": "8px 16px", "background": "#ef4444", "color": "#ffffff", "border": "none", "borderRadius": "6px", "fontSize": "14px", "fontWeight": "600", "cursor": "pointer"}}, ["Clear Completed"]) : __jacJsx("span", {}, [])]) : __jacJsx("span", {}, [])]);
}
function AppHeader() {
  let navigate = useNavigate();
  let auth = useAuth();
  let is_authed = jacIsLoggedIn();
  function handleLogout(event) {
    event.preventDefault();
    auth["logout"]();
    navigate("/login");
  }
  let auth_cta = __jacJsx(Link, {"to": "/login", "style": {"padding": "8px 14px", "borderRadius": "8px", "border": "1px solid #6366f1", "color": "#6366f1", "textDecoration": "none", "fontWeight": "600"}}, ["Sign in"]);
  if (is_authed) {
    auth_cta = __jacJsx("button", {"onClick": handleLogout, "style": {"padding": "8px 14px", "borderRadius": "8px", "border": "1px solid #ef4444", "background": "#fef2f2", "color": "#b91c1c", "cursor": "pointer"}}, ["Sign out"]);
  }
  let dashboard_link = null;
  if (is_authed) {
    dashboard_link = __jacJsx(Link, {"to": "/dashboard", "style": {"color": "#0f172a", "textDecoration": "none", "fontWeight": "600"}}, ["Dashboard"]);
  }
  return __jacJsx("header", {"style": {"background": "#ffffff", "borderBottom": "1px solid #e2e8f0", "padding": "12px 24px"}}, [__jacJsx("div", {"style": {"maxWidth": "1080px", "margin": "0 auto", "display": "flex", "alignItems": "center", "gap": "16px", "justifyContent": "space-between", "flexWrap": "wrap"}}, [__jacJsx("div", {"style": {"display": "flex", "alignItems": "center", "gap": "16px"}}, [__jacJsx("nav", {"style": {"display": "flex", "gap": "12px", "alignItems": "center"}}, [__jacJsx(Link, {"to": "/", "style": {"color": "#475569", "textDecoration": "none"}}, ["Home"]), __jacJsx(Link, {"to": "/login", "style": {"color": "#475569", "textDecoration": "none"}}, ["Login"]), __jacJsx(Link, {"to": "/signup", "style": {"color": "#475569", "textDecoration": "none"}}, ["Sign up"]), dashboard_link])]), auth_cta])]);
}
function app() {
  return __jacJsx(Router, {"defaultRoute": "/login"}, [__jacJsx("div", {"style": {"minHeight": "95vh", "font-family": "sans-serif", "transition": "background 0.3s ease", "background": "#f1f5f9"}}, [__jacJsx(AppHeader, {}, []), __jacJsx("main", {"style": {"maxWidth": "1080px", "margin": "0 auto", "width": "100%", "padding": "32px 16px"}}, [__jacJsx(Routes, {}, [__jacJsx(Route, {"path": "/login", "component": LoginPage}, []), __jacJsx(Route, {"path": "/signup", "component": SignupPage}, []), __jacJsx(Route, {"path": "/dashboard", "component": DashboardPage, "guard": jacIsLoggedIn}, [])])])])]);
}
export { AppHeader, DashboardPage, LoginPage, SignupPage, app, useAuth, useTodos };
