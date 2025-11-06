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
export function Button() {
  return __jacJsx("button", {}, ["Click Me"]);
}
