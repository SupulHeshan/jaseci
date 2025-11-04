# ============================================================================
# MAIN APPLICATION ENTRY POINT
# ============================================================================

include models;

cl import from .page_login { LoginPage }
cl import from .page_signup { SignupPage }
cl import from .page_todos { TodosPage }

cl {
    def App() -> any {
        loginRoute = {"path": "/login", "component": lambda -> any { return LoginPage(); }, "guard": None};
        signupRoute = {"path": "/signup", "component": lambda -> any { return SignupPage(); }, "guard": None};
        todosRoute = {"path": "/todos", "component": lambda -> any { return TodosPage(); }, "guard": jacIsLoggedIn};

        routes = [loginRoute, signupRoute, todosRoute];
        router = initRouter(routes, "/login");

        return <div style={{"minHeight": "100vh", "background": "#f9fafb"}}>
            {router.render()}
        </div>;
    }

    def jac_app() -> any {
        return App();
    }
}