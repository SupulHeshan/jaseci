import { useState, useEffect } from "react";
import { Button } from "./button.js";
function App() {
  let [count, setCount] = useState(0);
  useEffect(() => {
    console.log("Count: ", count);
  }, [count]);
  return __jacJsx("div", {}, [__jacJsx("h1", {}, ["Hello, World!"]), __jacJsx(Button, {}, []), __jacJsx("p", {}, ["Count: ", count]), __jacJsx("button", {"onClick": e => {
    setCount(count + 1);
  }}, ["Increment"])]);
}
