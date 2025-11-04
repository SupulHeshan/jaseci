cl def useAuth() -> dict {
    async def login(username: str, password: str) -> dict {
        success = await jacLogin(username, password);
        return {"success": success, "error": None if success else "Invalid credentials"};
    }

    async def signup(username: str, password: str, confirmPassword: str) -> dict {
        if password != confirmPassword {
            return {"success": False, "error": "Passwords do not match"};
        }
        result = await jacSignup(username, password);
        return {"success": result["success"] if "success" in result else False, "error": result["error"] if "error" in result else None};
    }

    def logout() -> None {
        jacLogout();
    }

    def isAuthenticated() -> bool {
        return jacIsLoggedIn();
    }

    return {"login": login, "signup": signup, "logout": logout, "isAuthenticated": isAuthenticated};
}
