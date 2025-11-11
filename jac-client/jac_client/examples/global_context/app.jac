cl import from react {useState, useEffect, useMemo, useContext, useRef}
cl import from "@jac-client/utils" {Router, Routes, Route, Link, Navigate, useNavigate, jacIsLoggedIn, jacLogin, jacSignup, __jacSpawn, jacLogout}
cl import from .ThemeContext {ThemeContext, getDefaultPalette}


cl{
    def buildPalette(mode: str, accent: str) -> dict {
        if mode == "dark" {
            return {
                "background": "#0f172a",
                "surface": "#111827",
                "border": "#94a3b859",
                "text": "#e2e8f0",
                "muted": "#94a3b8",
                "accent": accent,
                "accentText": "#0f172a"
            };
        }
        return {
            "background": "#f1f5f9",
            "surface": "#ffffff",
            "border": "#e2e8f0",
            "text": "#0f172a",
            "muted": "#475569",
            "accent": accent,
            "accentText": "#ffffff"
        };
    }

    def AboutPage() -> any {
        let theme = useContext(ThemeContext);
        let palette = theme["palette"] if theme and "palette" in theme else getDefaultPalette();
        let accent = theme["accent"] if theme and "accent" in theme else "#6366f1";
        let textColor = palette["text"] if "text" in palette else "#0f172a";
        let mutedColor = palette["muted"] if "muted" in palette else "#475569";
        let surfaceColor = palette["surface"] if "surface" in palette else "#ffffff";
        let borderColor = palette["border"] if "border" in palette else "#e2e8f0";
        let accentText = palette["accentText"] if "accentText" in palette else "#ffffff";

        let timeline = [
            {"title": "Jac graph", "body": "Walkers handle your data mutations so UI stays pure."},
            {"title": "React context", "body": "Theme tokens stream to every component via ThemeContext."},
            {"title": "Design system", "body": "Accent, surface, and text colors adapt automatically."}
        ];
        let timelineItems = [];
        for item in timeline {
            timelineItems.push(
                <li key={item["title"]} style={{"display": "grid", "gap": "6px", "padding": "16px", "borderRadius": "12px", "background": surfaceColor, "border": f"1px solid {borderColor}", "boxShadow": "0 12px 24px rgba(15,23,42,0.08)"}}>
                    <span style={{"fontWeight": "600", "color": textColor}}>{item["title"]}</span>
                    <span style={{"color": mutedColor}}>{item["body"]}</span>
                </li>
            );
        }

        return <div style={{"padding": "32px", "color": textColor, "display": "grid", "gap": "28px"}}>
            <header style={{"display": "grid", "gap": "12px"}}>
                <span style={{"textTransform": "uppercase", "letterSpacing": "0.18em", "fontSize": "12px", "color": mutedColor}}>about the stack</span>
                <h1 style={{"margin": "0", "fontSize": "30px", "color": textColor}}>Jac + React = realtime full-stack theming</h1>
                <p style={{"margin": "0", "color": mutedColor}}>
                    This playground demonstrates how a Jac backend cooperates with a React frontend. Theme changes ripple through every view while walkers keep data consistent.
                </p>
            </header>

            <section style={{"display": "grid", "gap": "16px", "gridTemplateColumns": "repeat(auto-fit, minmax(220px, 1fr))"}}>
                <div style={{"padding": "20px", "borderRadius": "16px", "background": accent, "color": accentText, "boxShadow": "0 24px 40px rgba(15,23,42,0.25)"}}>
                    <h2 style={{"margin": "0 0 8px"}}>Dynamic palette</h2>
                    <p style={{"margin": "0"}}>Toggle dark mode or swap accents to regenerate surface, border, and text tokens instantly.</p>
                </div>
                <div style={{"padding": "20px", "borderRadius": "16px", "background": surfaceColor, "border": f"1px solid {borderColor}", "boxShadow": "0 16px 32px rgba(15,23,42,0.07)"}}>
                    <h3 style={{"margin": "0 0 8px", "color": textColor}}>Context contract</h3>
                    <ul style={{"margin": "0", "padding": "0", "listStyle": "none", "display": "grid", "gap": "10px"}}>
                        <li style={{"color": mutedColor}}>mode → light or dark baseline</li>
                        <li style={{"color": mutedColor}}>accent → branded highlight color</li>
                        <li style={{"color": mutedColor}}>palette → derived primitives for UI</li>
                    </ul>
                </div>
            </section>

            <section>
                <h3 style={{"margin": "0 0 12px", "color": textColor}}>Build pipeline</h3>
                <ul style={{"margin": "0", "padding": "0", "listStyle": "none", "display": "grid", "gap": "12px"}}>{timelineItems}</ul>
            </section>
        </div>;
    }

    def ContectPage() -> any {
        let theme = useContext(ThemeContext);
        let palette = theme["palette"] if theme and "palette" in theme else getDefaultPalette();
        let accent = theme["accent"] if theme and "accent" in theme else "#6366f1";
        let textColor = palette["text"] if "text" in palette else "#0f172a";
        let mutedColor = palette["muted"] if "muted" in palette else "#475569";
        let surfaceColor = palette["surface"] if "surface" in palette else "#ffffff";
        let borderColor = palette["border"] if "border" in palette else "#e2e8f0";
        let accentText = palette["accentText"] if "accentText" in palette else "#ffffff";

        return <div style={{"padding": "32px", "color": textColor, "display": "grid", "gap": "24px"}}>
            <header style={{"display": "grid", "gap": "8px"}}>
                <h1 style={{"margin": "0", "color": accent}}>We’d love to hear from you</h1>
                <p style={{"margin": "0", "color": mutedColor}}>Theme toggles carry across the contact experience so everything stays legible.</p>
            </header>

            <section style={{"display": "grid", "gap": "20px", "gridTemplateColumns": "repeat(auto-fit, minmax(240px, 1fr))"}}>
                <div style={{"padding": "20px", "borderRadius": "16px", "background": surfaceColor, "border": f"1px solid {borderColor}"}}>
                    <h3 style={{"margin": "0 0 6px", "color": textColor}}>Support</h3>
                    <p style={{"margin": "0", "color": mutedColor}}>Open an issue or ping the team directly from the dashboard.</p>
                    <a href="mailto:support@jac.dev" style={{"marginTop": "12px", "display": "inline-block", "color": accent}}>support@jac.dev</a>
                </div>
                <div style={{"padding": "20px", "borderRadius": "16px", "background": accent, "color": accentText}}>
                    <h3 style={{"margin": "0 0 6px"}}>Community</h3>
                    <p style={{"margin": "0"}}>Join #theming channel to share palettes and get inspiration.</p>
                    <div style={{"marginTop": "12px", "display": "flex", "gap": "8px", "flexWrap": "wrap"}}>
                        <span style={{"padding": "6px 12px", "borderRadius": "999px", "background": "rgba(255,255,255,0.15)"}}>Discord</span>
                        <span style={{"padding": "6px 12px", "borderRadius": "999px", "background": "rgba(255,255,255,0.15)"}}>Forum</span>
                    </div>
                </div>
                <div style={{"padding": "20px", "borderRadius": "16px", "background": surfaceColor, "border": f"1px solid {borderColor}", "display": "grid", "gap": "10px"}}>
                    <h3 style={{"margin": "0", "color": textColor}}>Office hours</h3>
                    <p style={{"margin": "0", "color": mutedColor}}>Weekly live session on theming best practices.</p>
                    <div style={{"display": "flex", "alignItems": "center", "gap": "8px"}}>
                        <span style={{"width": "10px", "height": "10px", "borderRadius": "999px", "background": accent}}></span>
                        <span>Tuesdays · 3PM UTC</span>
                    </div>
                </div>
            </section>
        </div>;
    }

    def HomePage() -> any {
        let theme = useContext(ThemeContext);
        let palette = theme["palette"] if theme and "palette" in theme else getDefaultPalette();
        let accent = theme["accent"] if theme and "accent" in theme else "#6366f1";
        let textColor = palette["text"] if "text" in palette else "#0f172a";
        let mutedColor = palette["muted"] if "muted" in palette else "#475569";
        let surfaceColor = palette["surface"] if "surface" in palette else "#ffffff";
        let backgroundColor = palette["background"] if "background" in palette else "#f1f5f9";
        let borderColor = palette["border"] if "border" in palette else "#e2e8f0";
        let accentTextColor = palette["accentText"] if "accentText" in palette else "#ffffff";

        let paletteItems = [
            {"label": "Background", "value": backgroundColor},
            {"label": "Surface", "value": surfaceColor},
            {"label": "Border", "value": borderColor},
            {"label": "Text", "value": textColor},
            {"label": "Muted", "value": mutedColor},
            {"label": "Accent", "value": accent}
        ];
        let paletteCards = [];
        for item in paletteItems {
            paletteCards.push(
                <div key={item["label"]} style={{
                    "padding": "16px",
                    "borderRadius": "12px",
                    "border": f"1px solid {borderColor}",
                    "background": surfaceColor,
                    "boxShadow": "0 10px 30px rgba(15,23,42,0.08)",
                    "display": "flex",
                    "flexDirection": "column",
                    "gap": "12px"
                }}>
                    <div style={{"display": "flex", "alignItems": "center", "gap": "12px"}}>
                        <span style={{
                            "display": "inline-block",
                            "width": "38px",
                            "height": "38px",
                            "borderRadius": "12px",
                            "background": item["value"],
                            "border": f"1px solid {borderColor}",
                            "boxShadow": "0 10px 30px rgba(15,23,42,0.08)",
                        }}></span>
                        <div>
                            <h3 style={{"margin": "0", "fontSize": "16px", "color": textColor}}>{item["label"]}</h3>
                            <code style={{"color": mutedColor}}>{item["value"]}</code>
                        </div>
                    </div>
                </div>
            );
        }

        let heroBackground = f"linear-gradient(135deg, {accent} 0%, {backgroundColor} 70%)";

        return <div style={{"padding": "32px", "color": textColor, "display": "grid", "gap": "32px"}}>
            <section style={{
                "padding": "32px",
                "borderRadius": "20px",
                "background": heroBackground,
                "color": accentTextColor,
                "boxShadow": "0 20px 45px rgba(15,23,42,0.18)",
                "display": "grid",
                "gap": "16px",
                "alignItems": "center"
            }}>
                <span style={{"textTransform": "uppercase", "letterSpacing": "0.18em", "fontSize": "12px", "opacity": 0.85}}>theming demo</span>
                <h1 style={{"margin": "0", "fontSize": "32px", "lineHeight": 1.2}}>Preview the Jac React theme palette in real time.</h1>
                <p style={{"margin": "0", "fontSize": "16px", "maxWidth": "560px"}}>
                    Toggle dark mode or swap accent colors in the header to see these blocks update instantly. The UI pulls tokens from
                    <strong style={{"marginLeft": "4px"}}>ThemeContext</strong> so every element stays in sync.
                </p>
                <div style={{"display": "flex", "gap": "12px", "flexWrap": "wrap"}}>
                    <span style={{"padding": "8px 14px", "borderRadius": "999px", "background": surfaceColor, "color": textColor, "border": "1px solid rgba(15,23,42,0.12)", "fontWeight": "600"}}>Live preview</span>
                    <span style={{"padding": "8px 14px", "borderRadius": "999px", "background": "transparent", "border": "1px solid rgba(255,255,255,0.35)", "color": "inherit"}}>Context aware</span>
                </div>
            </section>

            <section style={{"display": "grid", "gap": "24px"}}>
                <header>
                    <h2 style={{"margin": "0 0 8px", "color": textColor}}>Palette tokens</h2>
                    <p style={{"margin": "0", "color": mutedColor}}>Each token is sourced from the active theme. Switch modes or accents to watch them refresh.</p>
                </header>
                <div style={{"display": "grid", "gap": "20px", "gridTemplateColumns": "repeat(auto-fit, minmax(220px, 1fr))"}}>{paletteCards}</div>
            </section>

            <section style={{
                "padding": "28px",
                "borderRadius": "18px",
                "border": f"1px solid {borderColor}",
                "background": surfaceColor,
                "display": "grid",
                "gap": "12px"
            }}>
                <h3 style={{"margin": "0", "color": textColor}}>How it works</h3>
                <p style={{"margin": "0", "color": mutedColor, "display": "flex", "flexWrap": "wrap", "gap": "4px", "lineHeight": 1.5}}>
                    <span>The theme provider broadcasts</span>
                    <code style={{"fontSize": "14px"}}>mode</code>
                    <span>,</span>
                    <code style={{"fontSize": "14px"}}>accent</code>
                    <span>, and a computed</span>
                    <code style={{"fontSize": "14px"}}>palette</code>
                    <span>. Our pages consume those values via</span>
                    <code style={{"fontSize": "14px"}}>useContext(ThemeContext)</code>
                    <span>to keep styling declarative.</span>
                </p>
                <div style={{"display": "grid", "gap": "10px", "gridTemplateColumns": "repeat(auto-fit, minmax(160px, 1fr))"}}>
                    <div style={{"padding": "16px", "borderRadius": "12px", "background": accent, "color": accentTextColor, "fontWeight": "600"}}>Accent aware buttons</div>
                    <div style={{"padding": "16px", "borderRadius": "12px", "background": backgroundColor, "color": textColor}}>Mode adaptive backgrounds</div>
                    <div style={{"padding": "16px", "borderRadius": "12px", "background": surfaceColor, "color": mutedColor}}>Text tokens</div>
                </div>
            </section>
        </div>;
    }

     def AppHeader() -> any {
        let theme = useContext(ThemeContext);
        let navigate = useNavigate();
        let palette = theme["palette"] if theme and "palette" in theme else getDefaultPalette();
        let accent = theme["accent"] if theme and "accent" in theme else "#6366f1";
        let mode = theme["mode"] if theme and "mode" in theme else "light";
        let authed = jacIsLoggedIn();

        def handleThemeToggle() -> None {
            if theme and "setTheme" in theme {
                theme["setTheme"]();
            }
        }

        def handleAccentSwitch(nextAccent: str) -> None {
            if theme and "setAccent" in theme {
                theme["setAccent"](nextAccent);
            }
        }

        let background = palette["surface"] if "surface" in palette else "#ffffff";
        let borderColor = palette["border"] if "border" in palette else "#e2e8f0";
        let textColor = palette["text"] if "text" in palette else "#0f172a";
        let themeLabel = "Dark mode";
        if mode != "light" {
            themeLabel = "Light mode";
        }

        let accentChoices = ["#6366f1", "#f97316", "#10b981", "#ec4899"];
        let accentButtons = [];
        for option in accentChoices {
            let isActive = option == accent;
            let border = "2px solid transparent";
            if isActive {
                border = "2px solid #fff";
            }
            accentButtons.push(
                <button
                    key={option}
                    onClick={lambda _: any -> None { handleAccentSwitch(option); }}
                    style={{
                        "width": "28px",
                        "height": "28px",
                        "borderRadius": "999px",
                        "border": border,
                        "background": option,
                        "cursor": "pointer",
                        "boxShadow": "0 0 0 1px rgba(15,23,42,0.1)",
                        "opacity": 1.0 if isActive else 0.7
                    }}
                    aria-label={f"Switch accent to {option}"}
                ></button>
            );
        }

        return <header style={{"background": background, "borderBottom": f"1px solid {borderColor}", "padding": "12px 24px"}}>
            <div style={{"maxWidth": "1080px", "margin": "0 auto", "display": "flex", "alignItems": "center", "gap": "16px"}}>
                <nav style={{"flex": "1", "display": "flex", "gap": "16px", "alignItems": "center"}}>
                    <Link to="/" style={{"color": textColor, "textDecoration": "none"}}>Home</Link>
                    <Link to="/about" style={{"color": textColor, "textDecoration": "none"}}>About</Link>
                    <Link to="/contact" style={{"color": textColor, "textDecoration": "none"}}>Contect</Link>
                </nav>
                <div style={{"display": "flex", "alignItems": "center", "gap": "12px"}}>
                    <div style={{"display": "flex", "gap": "6px"}}>{accentButtons}</div>
                    <button onClick={lambda _: any -> None { handleThemeToggle(); }} style={{"padding": "8px 12px", "borderRadius": "8px", "border": f"1px solid {borderColor}", "background": "transparent", "color": textColor, "cursor": "pointer"}}>{themeLabel}</button>
                </div>
            </div>
        </header>;
    }

    def app() -> any {
         let [theme, setTheme] = useState({"mode": "light", "accent": "#6366f1"});

        useEffect(lambda -> None {
            try {
                if globalThis and "localStorage" in globalThis {
                    let stored = globalThis.localStorage.getItem("jac.theme.preferences");
                    if stored {
                        let parsed = JSON.parse(stored);
                        if parsed and parsed.mode and parsed.accent {
                            setTheme({"mode": parsed.mode, "accent": parsed.accent});
                        }
                    }
                }
            } except Exception as err {
                console.warn("Failed to load theme preferences", err);
            }
        }, []);

        useEffect(lambda -> None {
            try {
                if globalThis and "localStorage" in globalThis {
                    globalThis.localStorage.setItem("jac.theme.preferences", JSON.stringify(theme));
                }
            } except Exception as err {
                console.warn("Failed to persist theme preferences", err);
            }
        }, [theme]);

        def setMode(nextMode: str) -> None {
            let normalized = nextMode;
            if normalized != "light" and normalized != "dark" {
                normalized = "light";
            }
            setTheme(lambda prev: dict -> dict {
                return {"mode": normalized, "accent": prev["accent"]};
            });
        }

        def setAccent(nextAccent: str) -> None {
            if not nextAccent {
                return None;
            }
            setTheme(lambda prev: dict -> dict {
                return {"mode": prev["mode"], "accent": nextAccent};
            });
        }

        def toggleTheme() -> None {
            setTheme(lambda prev: dict -> dict {
                let nextMode = "dark" if prev["mode"] == "light" else "light";
                return {"mode": nextMode, "accent": prev["accent"]};
            });
        }

        let palette = buildPalette(theme["mode"], theme["accent"]);
        let globalBackground = palette["background"] if "background" in palette else "#f1f5f9";
        let globalText = palette["text"] if "text" in palette else "#0f172a";

        let contextValue = {
            "mode": theme["mode"],
            "accent": theme["accent"],
            "palette": palette,
            "setTheme": toggleTheme,
            "setMode": setMode,
            "setAccent": setAccent
        };

        return <ThemeContext.Provider value={contextValue}>
            <Router defaultRoute="/">
                <div style={{"minHeight": "95vh","font-family": "sans-serif", "background": globalBackground, "color": globalText, "transition": "background 0.3s ease, color 0.3s ease"}}>
                    <AppHeader />
                    <main style={{"maxWidth": "1080px", "margin": "0 auto", "width": "100%", "padding": "32px 16px"}}>
                        <Routes>
                            <Route path="/" element={<HomePage/>} />
                            <Route path="/about" element={<AboutPage />} />
                            <Route path="/contact" element={<ContectPage />} />
                        </Routes>
                    </main>
                </div>
            </Router>
        </ThemeContext.Provider>;
    }
}