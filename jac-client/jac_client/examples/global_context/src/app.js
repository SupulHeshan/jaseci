import {__jacJsx} from "@jac-client/utils";
import { useState, useEffect, useMemo, useContext, useRef } from "react";
import { Router, Routes, Route, Link, Navigate, useNavigate, jacIsLoggedIn, jacLogin, jacSignup, __jacSpawn, jacLogout } from "@jac-client/utils";
import { ThemeContext, getDefaultPalette } from "./ThemeContext.js";
function buildPalette(mode, accent) {
  if (mode === "dark") {
    return {"background": "#0f172a", "surface": "#111827", "border": "#94a3b859", "text": "#e2e8f0", "muted": "#94a3b8", "accent": accent, "accentText": "#0f172a"};
  }
  return {"background": "#f1f5f9", "surface": "#ffffff", "border": "#e2e8f0", "text": "#0f172a", "muted": "#475569", "accent": accent, "accentText": "#ffffff"};
}
function AboutPage() {
  let theme = useContext(ThemeContext);
  let palette = theme && "palette" in theme ? theme["palette"] : getDefaultPalette();
  let accent = theme && "accent" in theme ? theme["accent"] : "#6366f1";
  let textColor = "text" in palette ? palette["text"] : "#0f172a";
  let mutedColor = "muted" in palette ? palette["muted"] : "#475569";
  let surfaceColor = "surface" in palette ? palette["surface"] : "#ffffff";
  let borderColor = "border" in palette ? palette["border"] : "#e2e8f0";
  let accentText = "accentText" in palette ? palette["accentText"] : "#ffffff";
  let timeline = [{"title": "Jac graph", "body": "Walkers handle your data mutations so UI stays pure."}, {"title": "React context", "body": "Theme tokens stream to every component via ThemeContext."}, {"title": "Design system", "body": "Accent, surface, and text colors adapt automatically."}];
  let timelineItems = [];
  for (const item of timeline) {
    timelineItems.push(__jacJsx("li", {"key": item["title"], "style": {"display": "grid", "gap": "6px", "padding": "16px", "borderRadius": "12px", "background": surfaceColor, "border": `1px solid ${borderColor}`, "boxShadow": "0 12px 24px rgba(15,23,42,0.08)"}}, [__jacJsx("span", {"style": {"fontWeight": "600", "color": textColor}}, [item["title"]]), __jacJsx("span", {"style": {"color": mutedColor}}, [item["body"]])]));
  }
  return __jacJsx("div", {"style": {"padding": "32px", "color": textColor, "display": "grid", "gap": "28px"}}, [__jacJsx("header", {"style": {"display": "grid", "gap": "12px"}}, [__jacJsx("span", {"style": {"textTransform": "uppercase", "letterSpacing": "0.18em", "fontSize": "12px", "color": mutedColor}}, ["about the stack"]), __jacJsx("h1", {"style": {"margin": "0", "fontSize": "30px", "color": textColor}}, ["Jac + React = realtime full-stack theming"]), __jacJsx("p", {"style": {"margin": "0", "color": mutedColor}}, ["This playground demonstrates how a Jac backend cooperates with a React frontend. Theme changes ripple through every view while walkers keep data consistent."])]), __jacJsx("section", {"style": {"display": "grid", "gap": "16px", "gridTemplateColumns": "repeat(auto-fit, minmax(220px, 1fr))"}}, [__jacJsx("div", {"style": {"padding": "20px", "borderRadius": "16px", "background": accent, "color": accentText, "boxShadow": "0 24px 40px rgba(15,23,42,0.25)"}}, [__jacJsx("h2", {"style": {"margin": "0 0 8px"}}, ["Dynamic palette"]), __jacJsx("p", {"style": {"margin": "0"}}, ["Toggle dark mode or swap accents to regenerate surface, border, and text tokens instantly."])]), __jacJsx("div", {"style": {"padding": "20px", "borderRadius": "16px", "background": surfaceColor, "border": `1px solid ${borderColor}`, "boxShadow": "0 16px 32px rgba(15,23,42,0.07)"}}, [__jacJsx("h3", {"style": {"margin": "0 0 8px", "color": textColor}}, ["Context contract"]), __jacJsx("ul", {"style": {"margin": "0", "padding": "0", "listStyle": "none", "display": "grid", "gap": "10px"}}, [__jacJsx("li", {"style": {"color": mutedColor}}, ["mode → light or dark baseline"]), __jacJsx("li", {"style": {"color": mutedColor}}, ["accent → branded highlight color"]), __jacJsx("li", {"style": {"color": mutedColor}}, ["palette → derived primitives for UI"])])])]), __jacJsx("section", {}, [__jacJsx("h3", {"style": {"margin": "0 0 12px", "color": textColor}}, ["Build pipeline"]), __jacJsx("ul", {"style": {"margin": "0", "padding": "0", "listStyle": "none", "display": "grid", "gap": "12px"}}, [timelineItems])])]);
}
function ContectPage() {
  let theme = useContext(ThemeContext);
  let palette = theme && "palette" in theme ? theme["palette"] : getDefaultPalette();
  let accent = theme && "accent" in theme ? theme["accent"] : "#6366f1";
  let textColor = "text" in palette ? palette["text"] : "#0f172a";
  let mutedColor = "muted" in palette ? palette["muted"] : "#475569";
  let surfaceColor = "surface" in palette ? palette["surface"] : "#ffffff";
  let borderColor = "border" in palette ? palette["border"] : "#e2e8f0";
  let accentText = "accentText" in palette ? palette["accentText"] : "#ffffff";
  return __jacJsx("div", {"style": {"padding": "32px", "color": textColor, "display": "grid", "gap": "24px"}}, [__jacJsx("header", {"style": {"display": "grid", "gap": "8px"}}, [__jacJsx("h1", {"style": {"margin": "0", "color": accent}}, ["We’d love to hear from you"]), __jacJsx("p", {"style": {"margin": "0", "color": mutedColor}}, ["Theme toggles carry across the contact experience so everything stays legible."])]), __jacJsx("section", {"style": {"display": "grid", "gap": "20px", "gridTemplateColumns": "repeat(auto-fit, minmax(240px, 1fr))"}}, [__jacJsx("div", {"style": {"padding": "20px", "borderRadius": "16px", "background": surfaceColor, "border": `1px solid ${borderColor}`}}, [__jacJsx("h3", {"style": {"margin": "0 0 6px", "color": textColor}}, ["Support"]), __jacJsx("p", {"style": {"margin": "0", "color": mutedColor}}, ["Open an issue or ping the team directly from the dashboard."]), __jacJsx("a", {"href": "mailto:support@jac.dev", "style": {"marginTop": "12px", "display": "inline-block", "color": accent}}, ["support@jac.dev"])]), __jacJsx("div", {"style": {"padding": "20px", "borderRadius": "16px", "background": accent, "color": accentText}}, [__jacJsx("h3", {"style": {"margin": "0 0 6px"}}, ["Community"]), __jacJsx("p", {"style": {"margin": "0"}}, ["Join #theming channel to share palettes and get inspiration."]), __jacJsx("div", {"style": {"marginTop": "12px", "display": "flex", "gap": "8px", "flexWrap": "wrap"}}, [__jacJsx("span", {"style": {"padding": "6px 12px", "borderRadius": "999px", "background": "rgba(255,255,255,0.15)"}}, ["Discord"]), __jacJsx("span", {"style": {"padding": "6px 12px", "borderRadius": "999px", "background": "rgba(255,255,255,0.15)"}}, ["Forum"])])]), __jacJsx("div", {"style": {"padding": "20px", "borderRadius": "16px", "background": surfaceColor, "border": `1px solid ${borderColor}`, "display": "grid", "gap": "10px"}}, [__jacJsx("h3", {"style": {"margin": "0", "color": textColor}}, ["Office hours"]), __jacJsx("p", {"style": {"margin": "0", "color": mutedColor}}, ["Weekly live session on theming best practices."]), __jacJsx("div", {"style": {"display": "flex", "alignItems": "center", "gap": "8px"}}, [__jacJsx("span", {"style": {"width": "10px", "height": "10px", "borderRadius": "999px", "background": accent}}, []), __jacJsx("span", {}, ["Tuesdays · 3PM UTC"])])])])]);
}
function HomePage() {
  let theme = useContext(ThemeContext);
  let palette = theme && "palette" in theme ? theme["palette"] : getDefaultPalette();
  let accent = theme && "accent" in theme ? theme["accent"] : "#6366f1";
  let textColor = "text" in palette ? palette["text"] : "#0f172a";
  let mutedColor = "muted" in palette ? palette["muted"] : "#475569";
  let surfaceColor = "surface" in palette ? palette["surface"] : "#ffffff";
  let backgroundColor = "background" in palette ? palette["background"] : "#f1f5f9";
  let borderColor = "border" in palette ? palette["border"] : "#e2e8f0";
  let accentTextColor = "accentText" in palette ? palette["accentText"] : "#ffffff";
  let paletteItems = [{"label": "Background", "value": backgroundColor}, {"label": "Surface", "value": surfaceColor}, {"label": "Border", "value": borderColor}, {"label": "Text", "value": textColor}, {"label": "Muted", "value": mutedColor}, {"label": "Accent", "value": accent}];
  let paletteCards = [];
  for (const item of paletteItems) {
    paletteCards.push(__jacJsx("div", {"key": item["label"], "style": {"padding": "16px", "borderRadius": "12px", "border": `1px solid ${borderColor}`, "background": surfaceColor, "boxShadow": "0 10px 30px rgba(15,23,42,0.08)", "display": "flex", "flexDirection": "column", "gap": "12px"}}, [__jacJsx("div", {"style": {"display": "flex", "alignItems": "center", "gap": "12px"}}, [__jacJsx("span", {"style": {"display": "inline-block", "width": "38px", "height": "38px", "borderRadius": "12px", "background": item["value"], "border": `1px solid ${borderColor}`, "boxShadow": "0 10px 30px rgba(15,23,42,0.08)"}}, []), __jacJsx("div", {}, [__jacJsx("h3", {"style": {"margin": "0", "fontSize": "16px", "color": textColor}}, [item["label"]]), __jacJsx("code", {"style": {"color": mutedColor}}, [item["value"]])])])]));
  }
  let heroBackground = `linear-gradient(135deg, ${accent} 0%, ${backgroundColor} 70%)`;
  return __jacJsx("div", {"style": {"padding": "32px", "color": textColor, "display": "grid", "gap": "32px"}}, [__jacJsx("section", {"style": {"padding": "32px", "borderRadius": "20px", "background": heroBackground, "color": accentTextColor, "boxShadow": "0 20px 45px rgba(15,23,42,0.18)", "display": "grid", "gap": "16px", "alignItems": "center"}}, [__jacJsx("span", {"style": {"textTransform": "uppercase", "letterSpacing": "0.18em", "fontSize": "12px", "opacity": 0.85}}, ["theming demo"]), __jacJsx("h1", {"style": {"margin": "0", "fontSize": "32px", "lineHeight": 1.2}}, ["Preview the Jac React theme palette in real time."]), __jacJsx("p", {"style": {"margin": "0", "fontSize": "16px", "maxWidth": "560px"}}, ["Toggle dark mode or swap accent colors in the header to see these blocks update instantly. The UI pulls tokens from", __jacJsx("strong", {"style": {"marginLeft": "4px"}}, ["ThemeContext"]), " so every element stays in sync."]), __jacJsx("div", {"style": {"display": "flex", "gap": "12px", "flexWrap": "wrap"}}, [__jacJsx("span", {"style": {"padding": "8px 14px", "borderRadius": "999px", "background": surfaceColor, "color": textColor, "border": "1px solid rgba(15,23,42,0.12)", "fontWeight": "600"}}, ["Live preview"]), __jacJsx("span", {"style": {"padding": "8px 14px", "borderRadius": "999px", "background": "transparent", "border": "1px solid rgba(255,255,255,0.35)", "color": "inherit"}}, ["Context aware"])])]), __jacJsx("section", {"style": {"display": "grid", "gap": "24px"}}, [__jacJsx("header", {}, [__jacJsx("h2", {"style": {"margin": "0 0 8px", "color": textColor}}, ["Palette tokens"]), __jacJsx("p", {"style": {"margin": "0", "color": mutedColor}}, ["Each token is sourced from the active theme. Switch modes or accents to watch them refresh."])]), __jacJsx("div", {"style": {"display": "grid", "gap": "20px", "gridTemplateColumns": "repeat(auto-fit, minmax(220px, 1fr))"}}, [paletteCards])]), __jacJsx("section", {"style": {"padding": "28px", "borderRadius": "18px", "border": `1px solid ${borderColor}`, "background": surfaceColor, "display": "grid", "gap": "12px"}}, [__jacJsx("h3", {"style": {"margin": "0", "color": textColor}}, ["How it works"]), __jacJsx("p", {"style": {"margin": "0", "color": mutedColor, "display": "flex", "flexWrap": "wrap", "gap": "4px", "lineHeight": 1.5}}, [__jacJsx("span", {}, ["The theme provider broadcasts"]), __jacJsx("code", {"style": {"fontSize": "14px"}}, ["mode"]), __jacJsx("span", {}, [","]), __jacJsx("code", {"style": {"fontSize": "14px"}}, ["accent"]), __jacJsx("span", {}, [", and a computed"]), __jacJsx("code", {"style": {"fontSize": "14px"}}, ["palette"]), __jacJsx("span", {}, [". Our pages consume those values via"]), __jacJsx("code", {"style": {"fontSize": "14px"}}, ["useContext(ThemeContext)"]), __jacJsx("span", {}, ["to keep styling declarative."])]), __jacJsx("div", {"style": {"display": "grid", "gap": "10px", "gridTemplateColumns": "repeat(auto-fit, minmax(160px, 1fr))"}}, [__jacJsx("div", {"style": {"padding": "16px", "borderRadius": "12px", "background": accent, "color": accentTextColor, "fontWeight": "600"}}, ["Accent aware buttons"]), __jacJsx("div", {"style": {"padding": "16px", "borderRadius": "12px", "background": backgroundColor, "color": textColor}}, ["Mode adaptive backgrounds"]), __jacJsx("div", {"style": {"padding": "16px", "borderRadius": "12px", "background": surfaceColor, "color": mutedColor}}, ["Text tokens"])])])]);
}
function AppHeader() {
  let theme = useContext(ThemeContext);
  let navigate = useNavigate();
  let palette = theme && "palette" in theme ? theme["palette"] : getDefaultPalette();
  let accent = theme && "accent" in theme ? theme["accent"] : "#6366f1";
  let mode = theme && "mode" in theme ? theme["mode"] : "light";
  let authed = jacIsLoggedIn();
  function handleThemeToggle() {
    if (theme && "setTheme" in theme) {
      theme["setTheme"]();
    }
  }
  function handleAccentSwitch(nextAccent) {
    if (theme && "setAccent" in theme) {
      theme["setAccent"](nextAccent);
    }
  }
  let background = "surface" in palette ? palette["surface"] : "#ffffff";
  let borderColor = "border" in palette ? palette["border"] : "#e2e8f0";
  let textColor = "text" in palette ? palette["text"] : "#0f172a";
  let themeLabel = "Dark mode";
  if (mode !== "light") {
    themeLabel = "Light mode";
  }
  let accentChoices = ["#6366f1", "#f97316", "#10b981", "#ec4899"];
  let accentButtons = [];
  for (const option of accentChoices) {
    let isActive = option === accent;
    let border = "2px solid transparent";
    if (isActive) {
      border = "2px solid #fff";
    }
    accentButtons.push(__jacJsx("button", {"key": option, "onClick": _ => {
      handleAccentSwitch(option);
    }, "style": {"width": "28px", "height": "28px", "borderRadius": "999px", "border": border, "background": option, "cursor": "pointer", "boxShadow": "0 0 0 1px rgba(15,23,42,0.1)", "opacity": isActive ? 1.0 : 0.7}, "aria-label": `Switch accent to ${option}`}, []));
  }
  return __jacJsx("header", {"style": {"background": background, "borderBottom": `1px solid ${borderColor}`, "padding": "12px 24px"}}, [__jacJsx("div", {"style": {"maxWidth": "1080px", "margin": "0 auto", "display": "flex", "alignItems": "center", "gap": "16px"}}, [__jacJsx("nav", {"style": {"flex": "1", "display": "flex", "gap": "16px", "alignItems": "center"}}, [__jacJsx(Link, {"to": "/", "style": {"color": textColor, "textDecoration": "none"}}, ["Home"]), __jacJsx(Link, {"to": "/about", "style": {"color": textColor, "textDecoration": "none"}}, ["About"]), __jacJsx(Link, {"to": "/contact", "style": {"color": textColor, "textDecoration": "none"}}, ["Contect"])]), __jacJsx("div", {"style": {"display": "flex", "alignItems": "center", "gap": "12px"}}, [__jacJsx("div", {"style": {"display": "flex", "gap": "6px"}}, [accentButtons]), __jacJsx("button", {"onClick": _ => {
    handleThemeToggle();
  }, "style": {"padding": "8px 12px", "borderRadius": "8px", "border": `1px solid ${borderColor}`, "background": "transparent", "color": textColor, "cursor": "pointer"}}, [themeLabel])])])]);
}
function app() {
  let [theme, setTheme] = useState({"mode": "light", "accent": "#6366f1"});
  useEffect(() => {
    try {
      if (globalThis && "localStorage" in globalThis) {
        let stored = globalThis.localStorage.getItem("jac.theme.preferences");
        if (stored) {
          let parsed = JSON.parse(stored);
          if (parsed && parsed.mode && parsed.accent) {
            setTheme({"mode": parsed.mode, "accent": parsed.accent});
          }
        }
      }
    } catch (err) {
      console.warn("Failed to load theme preferences", err);
    }
  }, []);
  useEffect(() => {
    try {
      if (globalThis && "localStorage" in globalThis) {
        globalThis.localStorage.setItem("jac.theme.preferences", JSON.stringify(theme));
      }
    } catch (err) {
      console.warn("Failed to persist theme preferences", err);
    }
  }, [theme]);
  function setMode(nextMode) {
    let normalized = nextMode;
    if (normalized !== "light" && normalized !== "dark") {
      normalized = "light";
    }
    setTheme(prev => {
      return {"mode": normalized, "accent": prev["accent"]};
    });
  }
  function setAccent(nextAccent) {
    if (!nextAccent) {
      return null;
    }
    setTheme(prev => {
      return {"mode": prev["mode"], "accent": nextAccent};
    });
  }
  function toggleTheme() {
    setTheme(prev => {
      let nextMode = prev["mode"] === "light" ? "dark" : "light";
      return {"mode": nextMode, "accent": prev["accent"]};
    });
  }
  let palette = buildPalette(theme["mode"], theme["accent"]);
  let globalBackground = "background" in palette ? palette["background"] : "#f1f5f9";
  let globalText = "text" in palette ? palette["text"] : "#0f172a";
  let contextValue = {"mode": theme["mode"], "accent": theme["accent"], "palette": palette, "setTheme": toggleTheme, "setMode": setMode, "setAccent": setAccent};
  return __jacJsx(ThemeContext.Provider, {"value": contextValue}, [__jacJsx(Router, {"defaultRoute": "/"}, [__jacJsx("div", {"style": {"minHeight": "95vh", "font-family": "sans-serif", "background": globalBackground, "color": globalText, "transition": "background 0.3s ease, color 0.3s ease"}}, [__jacJsx(AppHeader, {}, []), __jacJsx("main", {"style": {"maxWidth": "1080px", "margin": "0 auto", "width": "100%", "padding": "32px 16px"}}, [__jacJsx(Routes, {}, [__jacJsx(Route, {"path": "/", "element": __jacJsx(HomePage, {}, [])}, []), __jacJsx(Route, {"path": "/about", "element": __jacJsx(AboutPage, {}, [])}, []), __jacJsx(Route, {"path": "/contact", "element": __jacJsx(ContectPage, {}, [])}, [])])])])])]);
}
export { AboutPage, AppHeader, ContectPage, HomePage, app, buildPalette };
