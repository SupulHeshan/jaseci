import {__jacJsx} from "@jac-client/utils";
import { useState, useEffect } from "react";
import { Router, Routes, Route, Link } from "@jac-client/utils";
function Home() {
  return __jacJsx("div", {}, [__jacJsx("h1", {}, ["Home Page"]), __jacJsx("p", {}, ["Welcome to the home page!"]), __jacJsx("p", {}, ["This is a simple routing example using React-style routing."])]);
}
function About() {
  return __jacJsx("div", {}, [__jacJsx("h1", {}, ["About Page"]), __jacJsx("p", {}, ["This is the about page."]), __jacJsx("p", {}, ["Learn more about our application here."])]);
}
function Contact() {
  return __jacJsx("div", {}, [__jacJsx("h1", {}, ["Contact Page"]), __jacJsx("p", {}, ["Get in touch with us!"]), __jacJsx("p", {}, ["Email: contact@example.com"])]);
}
function Navigation() {
  return __jacJsx("nav", {"style": {"padding": "1rem", "backgroundColor": "#f0f0f0", "marginBottom": "1rem"}}, [__jacJsx(Link, {"to": "/"}, ["Home"]), " | ", __jacJsx(Link, {"to": "/about"}, ["About"]), " | ", __jacJsx(Link, {"to": "/contact"}, ["Contact"])]);
}
function app() {
  return __jacJsx(Router, {"defaultRoute": "/"}, [__jacJsx("div", {}, [__jacJsx(Navigation, {}, []), __jacJsx(Routes, {}, [__jacJsx(Route, {"path": "/", "component": Home}, []), __jacJsx(Route, {"path": "/about", "component": About}, []), __jacJsx(Route, {"path": "/contact", "component": Contact}, [])])])]);
}
export { About, Contact, Home, Navigation, app };
