import * as React from "react";
import * as ReactDOM from "react-dom/client";
function __jacJsx(tag, props, children) {
  if (tag === null) {
    tag = React.Fragment;
  }
  let childrenArray = [];
  if (children !== null) {
    if (Array.isArray(children)) {
      childrenArray = children;
    } else {
      childrenArray = [children];
    }
  }
  let reactChildren = [];
  for (const child of childrenArray) {
    if (child !== null) {
      reactChildren.push(child);
    }
  }
  if (reactChildren.length > 0) {
    let args = [tag, props];
    for (const child of reactChildren) {
      args.push(child);
    }
    return React.createElement.apply(React, args);
  } else {
    return React.createElement(tag, props);
  }
}
const __jacReactiveContext = {"signals": [], "currentComponent": null, "currentEffect": null, "mountedComponents": {}};
function createSignal(initialValue) {
  let signalId = __jacReactiveContext.signals.length;
  let signalData = {"value": initialValue, "subscribers": []};
  __jacReactiveContext.signals.push(signalData);
  function getter() {
    __jacTrackDependency(signalData.subscribers);
    return signalData.value;
  }
  function setter(newValue) {
    if (newValue !== signalData.value) {
      signalData.value = newValue;
      __jacNotifySubscribers(signalData.subscribers);
    }
  }
  return [getter, setter];
}
function onMount(mountFn) {
  let currentComponent = __jacReactiveContext.currentComponent;
  if (!currentComponent) {
    __jacRunEffect(mountFn);
    return;
  }
  if (!__jacReactiveContext.mountedComponents) {
    __jacReactiveContext.mountedComponents = {};
  }
  let componentId = `${currentComponent}`;
  if (!__jacHasOwn(__jacReactiveContext.mountedComponents, componentId)) {
    __jacReactiveContext.mountedComponents[componentId] = true;
    try {
      setTimeout(() => {
        __jacRunEffect(mountFn);
      }, 0);
    } catch {
      __jacRunEffect(mountFn);
    }
  }
}
function __jacTrackDependency(subscribers) {
  let currentEffect = __jacReactiveContext.currentEffect;
  if (currentEffect) {
    let alreadySubscribed = false;
    for (const sub of subscribers) {
      if (sub === currentEffect) {
        alreadySubscribed = true;
      }
    }
    if (!alreadySubscribed) {
      subscribers.push(currentEffect);
    }
  }
  let currentComponent = __jacReactiveContext.currentComponent;
  if (currentComponent) {
    let alreadySubscribed = false;
    for (const sub of subscribers) {
      if (sub === currentComponent) {
        alreadySubscribed = true;
      }
    }
    if (!alreadySubscribed) {
      subscribers.push(currentComponent);
    }
  }
}
function __jacNotifySubscribers(subscribers) {
  for (const subscriber of subscribers) {
    if (subscriber && subscriber !== null) {
      try {
        if (subscriber.call || subscriber.apply) {
          __jacRunEffect(subscriber);
        }
      } catch {}
    }
  }
}
function __jacRunEffect(effectFn) {
  let previousEffect = __jacReactiveContext.currentEffect;
  __jacReactiveContext.currentEffect = effectFn;
  try {
    effectFn();
  } catch (err) {
    console.error("[Jac] Error in effect:", err);
  }
  __jacReactiveContext.currentEffect = previousEffect;
}
const __jacRouterContext = React.createContext(null);
function Router(props) {
  let children = "children" in props ? props["children"] : [];
  let defaultRoute = "defaultRoute" in props ? props["defaultRoute"] : "/";
  let basename = "basename" in props ? props["basename"] : "";
  let initialPath = __jacGetHashPath();
  if (!initialPath) {
    initialPath = defaultRoute;
  }
  if (basename && initialPath.startsWith(basename)) {
    initialPath = initialPath.slice(len(basename));
  }
  if (initialPath && !initialPath.startsWith("/")) {
    initialPath = "/" + initialPath;
  }
  let [pathState, setPathState] = React.useState(initialPath);
  function currentPath() {
    return pathState;
  }
  function navigateTo(path) {
    let normalizedPath = path;
    if (normalizedPath && !normalizedPath.startsWith("/")) {
      normalizedPath = "/" + normalizedPath;
    }
    let fullPath = basename ? basename + normalizedPath : normalizedPath;
    window.location.hash = "#" + fullPath;
    setPathState(normalizedPath);
  }
  React.useEffect(() => {
    function handleHashChange(event) {
      let newPath = __jacGetHashPath();
      if (basename && newPath.startsWith(basename)) {
        newPath = newPath.slice(len(basename));
      }
      if (!newPath) {
        newPath = defaultRoute;
      }
      if (newPath && !newPath.startsWith("/")) {
        newPath = "/" + newPath;
      }
      setPathState(newPath);
    }
    window.addEventListener("hashchange", handleHashChange);
    window.addEventListener("popstate", handleHashChange);
    return () => {
      window.removeEventListener("hashchange", handleHashChange);
      window.removeEventListener("popstate", handleHashChange);
    };
  }, []);
  let routerValue = {"location": currentPath, "navigate": navigateTo, "basename": basename};
  return __jacJsx(__jacRouterContext.Provider, {"value": routerValue}, children);
}
function Route(props) {
  let path = "path" in props ? props["path"] : "/";
  let elementProp = null;
  if ("element" in props) {
    elementProp = props["element"];
  }
  let component = "component" in props ? props["component"] : null;
  let guard = "guard" in props ? props["guard"] : null;
  let router = React.useContext(__jacRouterContext);
  if (!router) {
    console.error("[Jac] Route must be used inside Router");
    return null;
  }
  let currentPath = router.location();
  let isMatch = currentPath === path;
  if (!isMatch) {
    return null;
  }
  if (guard && !guard()) {
    return __jacJsx("div", {}, ["Access Denied"]);
  }
  if (component) {
    return component();
  }
  if (elementProp) {
    return elementProp;
  }
  return null;
}
function Routes(props) {
  let children = "children" in props ? props["children"] : [];
  let router = React.useContext(__jacRouterContext);
  if (!router) {
    console.error("[Jac] Routes must be used inside Router");
    return __jacJsx("div", {}, ["Router context not found"]);
  }
  let currentPath = router.location();
  let childrenArray = [];
  if (children !== null) {
    if (Array.isArray(children)) {
      childrenArray = children;
    } else {
      childrenArray = [children];
    }
  }
  for (const child of childrenArray) {
    if (child && child !== null && child.props) {
      let routePath = child.props.path ? child.props.path : "/";
      if (routePath === currentPath) {
        let guard = child.props.guard ? child.props.guard : null;
        if (guard && !guard()) {
          return __jacJsx("div", {}, ["Access Denied"]);
        }
        if (child.props.component) {
          return child.props.component();
        } else {
          let elementValue = child.props["element"] !== null ? child.props["element"] : null;
          if (elementValue) {
            return elementValue;
          }
        }
      }
    }
  }
  return __jacJsx("div", {}, ["404 - Route not found: ", currentPath]);
}
function Link(props) {
  let to = "to" in props ? props["to"] : "/";
  let href = "href" in props ? props["href"] : to;
  if (href && !href.startsWith("/")) {
    href = "/" + href;
  }
  let children = "children" in props ? props["children"] : [];
  let router = React.useContext(__jacRouterContext);
  function handleClick(event) {
    event.preventDefault();
    if (router) {
      router.navigate(href);
    } else {
      window.location.hash = "#" + href;
    }
  }
  let childrenArray = [];
  if (children !== null) {
    if (Array.isArray(children)) {
      childrenArray = children;
    } else {
      childrenArray = [children];
    }
  }
  if (router && router.basename) {
    let fullHref = "#" + router.basename + href;
  } else {
    fullHref = "#" + href;
  }
  if (!fullHref.startsWith("#")) {
    let fullHref = "#" + fullHref;
  }
  return __jacJsx("a", {"href": fullHref, "onClick": handleClick}, childrenArray);
}
function Navigate(props) {
  let to = "to" in props ? props["to"] : "/";
  let replace = "replace" in props ? props["replace"] : false;
  let router = React.useContext(__jacRouterContext);
  if (router) {
    router.navigate(to);
  } else {
    window.location.hash = "#" + to;
  }
  return null;
}
function useNavigate() {
  let router = React.useContext(__jacRouterContext);
  if (!router) {
    console.error("[Jac] useNavigate must be used inside Router");
    return path => {
      window.location.hash = "#" + path;
    };
  }
  return router.navigate;
}
function useLocation() {
  let router = React.useContext(__jacRouterContext);
  if (!router) {
    console.error("[Jac] useLocation must be used inside Router");
    return {"pathname": __jacGetHashPath()};
  }
  return {"pathname": router.location()};
}
function useRouter() {
  let router = React.useContext(__jacRouterContext);
  if (!router) {
    console.warn("[Jac] useRouter must be used inside Router");
    return null;
  }
  return router;
}
function navigate(path) {
  let router = __jacReactiveContext.router;
  if (router) {
    router.navigate(path);
  } else {
    window.location.hash = "#" + path;
  }
}
function __jacGetHashPath() {
  let hash = window.location.hash;
  if (hash) {
    return hash.slice(1);
  }
  return "";
}
async function __jacSpawn(left, right, fields) {
  let token = __getLocalStorage("jac_token");
  let url = `/walker/${left}`;
  if (right !== "") {
    url = `/walker/${left}/${right}`;
  }
  let response = await fetch(url, {"method": "POST", "accept": "application/json", "headers": {"Content-Type": "application/json", "Authorization": token ? `Bearer ${token}` : ""}, "body": JSON.stringify({"fields": fields})});
  if (!response.ok) {
    let error_text = await response.json();
    throw new Error(`Walker ${walker} failed: ${error_text}`);
  }
  return await response.json();
}
async function __jacCallFunction(function_name, args) {
  let token = __getLocalStorage("jac_token");
  let response = await fetch(`/function/${function_name}`, {"method": "POST", "headers": {"Content-Type": "application/json", "Authorization": token ? `Bearer ${token}` : ""}, "body": JSON.stringify({"args": args})});
  if (!response.ok) {
    let error_text = await response.text();
    throw new Error(`Function ${function_name} failed: ${error_text}`);
  }
  let data = JSON.parse(await response.text());
  return data["result"];
}
async function jacSignup(username, password) {
  let response = await fetch("/user/create", {"method": "POST", "headers": {"Content-Type": "application/json"}, "body": JSON.stringify({"username": username, "password": password})});
  if (response.ok) {
    let data = JSON.parse(await response.text());
    let token = data["token"];
    if (token) {
      __setLocalStorage("jac_token", token);
      return {"success": true, "token": token, "username": username};
    }
    return {"success": false, "error": "No token received"};
  } else {
    let error_text = await response.text();
    try {
      let error_data = JSON.parse(error_text);
      return {"success": false, "error": error_data["error"] !== null ? error_data["error"] : "Signup failed"};
    } catch {
      return {"success": false, "error": error_text};
    }
  }
}
async function jacLogin(username, password) {
  let response = await fetch("/user/login", {"method": "POST", "headers": {"Content-Type": "application/json"}, "body": JSON.stringify({"username": username, "password": password})});
  if (response.ok) {
    let data = JSON.parse(await response.text());
    let token = data["token"];
    if (token) {
      __setLocalStorage("jac_token", token);
      return true;
    }
  }
  return false;
}
function jacLogout() {
  __removeLocalStorage("jac_token");
}
function jacIsLoggedIn() {
  let token = __getLocalStorage("jac_token");
  return token !== null && token !== "";
}
function __getLocalStorage(key) {
  let storage = globalThis.localStorage;
  return storage ? storage.getItem(key) : "";
}
function __setLocalStorage(key, value) {
  let storage = globalThis.localStorage;
  if (storage) {
    storage.setItem(key, value);
  }
}
function __removeLocalStorage(key) {
  let storage = globalThis.localStorage;
  if (storage) {
    storage.removeItem(key);
  }
}
function __objectKeys(obj) {
  if (obj === null) {
    return [];
  }
  return Object.keys(obj);
}
function __jacHasOwn(obj, key) {
  try {
    return Object.prototype.hasOwnProperty.call(obj, key);
  } catch {
    return false;
  }
}
export { Link, Navigate, Route, Router, Routes, __getLocalStorage, __jacCallFunction, __jacGetHashPath, __jacHasOwn, __jacJsx, __jacNotifySubscribers, __jacRunEffect, __jacSpawn, __jacTrackDependency, __objectKeys, __removeLocalStorage, __setLocalStorage, createSignal, jacIsLoggedIn, jacLogin, jacLogout, jacSignup, navigate, onMount, useLocation, useNavigate, useRouter };
