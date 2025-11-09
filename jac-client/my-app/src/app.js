import { useState, useEffect } from "react";
import { log_test, jacSpawn, jacIsLoggedIn } from "@jac-client/utils";
function App() {
  let [count, setCount] = useState(0);
  useEffect(() => {
    console.log("Count: ", count);
  }, [count]);
  return __jacJsx("div", {}, [__jacJsx("h1", {}, ["Hello, World!"]), __jacJsx("p", {}, ["Count: ", count]), __jacJsx("button", {"onClick": e => {
    setCount(count + 1);
  }}, ["Increment"])]);
}
import * as React from "react";
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
export { App };
