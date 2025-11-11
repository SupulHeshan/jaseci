// ThemeContext.js
import { createContext } from "react";

const defaultPalette = {
  background: "#f1f5f9",
  surface: "#ffffff",
  border: "#94a3b859",
  text: "#0f172a",
  muted: "#475569",
  accentText: "#ffffff",
};

export const ThemeContext = createContext({
  mode: "light",
  accent: "#6366f1",
  palette: defaultPalette,
  setTheme: () => {},
  setMode: () => {},
  setAccent: () => {},
});

export const getDefaultPalette = () => defaultPalette;
