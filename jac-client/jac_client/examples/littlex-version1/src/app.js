import {__jacJsx} from "@jac-client/utils";
import { useState, useEffect } from "react";
import { Router, Routes, Route, Link, Navigate, useNavigate, jacIsLoggedIn, jacLogin, jacSignup, __jacSpawn, jacLogout } from "@jac-client/utils";
import { useBearStore } from "./store.js";
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
async function search_users(query) {
  let users = [];
  try {
    let response = await __jacSpawn("search_users", "", {"query": "alice"});
    users = response.reports ? flattenReports(response.reports) : [];
    return users;
  } catch (e) {
    console.log("Error loading feed:", e);
    return users;
  }
}
function app() {
  async function handleSearch() {
    let searchUsers = await search_users("alice");
    console.log("Search Users Result:", searchUsers);
  }
  let bearsStore = useBearStore();
  let bears = bearsStore["bears"];
  let increasePopulation = bearsStore["increasePopulation"];
  let removeAllBears = bearsStore["removeAllBears"];
  let [count, setCount] = useState(0);
  useEffect(() => {
    console.log("Count: ", count);
  }, [count]);
  useEffect(() => {
    handleSearch();
  }, []);
  return __jacJsx("div", {}, [__jacJsx("h1", {"className": "text-3xl text-blue-500"}, ["Hello, World!"]), __jacJsx("p", {}, ["Count: ", count]), __jacJsx("button", {"onClick": e => {
    setCount(count + 1);
  }}, ["Increment"]), __jacJsx("p", {}, ["Bears: ", bears]), __jacJsx("button", {"onClick": e => {
    increasePopulation();
  }}, ["Increase Bears"]), __jacJsx("button", {"onClick": e => {
    removeAllBears();
  }}, ["Remove All Bears"])]);
}
export { app, flattenReports, search_users };
