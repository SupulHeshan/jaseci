"""Client-side runtime for Jac JSX and walker interactions."""

cl import from 'react' {* as React}
cl {
def __jacJsx(tag: any, props: dict = {}, children: any = []) -> any {
    # Handle fragments: when tag is None/null, use React.Fragment
    if tag == None {
        tag = React.Fragment;
    }

    childrenArray = [];
    if children != None {
        if Array.isArray(children) {
            childrenArray = children;
        } else {
            childrenArray = [children];
        }
    }

    # Filter out null/undefined children
    reactChildren = [];
    for child in childrenArray {
        if child != None {
            reactChildren.push(child);
        }
    }

    if reactChildren.length > 0 {
        args = [tag, props];
        for child in reactChildren {
            args.push(child);
        }
        return React.createElement.apply(React, args);
    } else {
        return React.createElement(tag, props);
    }
}
async def __jacSpawn(walker: str, fields: dict = {}) -> any {
    token = __getLocalStorage("jac_token");

    response = await fetch(
        f"/walker/{walker}",
        {
            "method": "POST",
            "accept": "application/json",
            "headers": {
                "Content-Type": "application/json",
                "Authorization": f"Bearer {token}" if token else ""
            },
            "body": JSON.stringify({"fields": {"nd": "root", **fields}})
        }
    );

    if not response.ok {
        error_text = await response.json();
        raise Exception(f"Walker {walker} failed: {error_text}");
    }

    return await response.json();
}

# Function call function - calls server-side functions from client
async def __jacCallFunction(function_name: str, args: dict = {}) -> any {
    token = __getLocalStorage("jac_token");

    response = await fetch(
        f"/function/{function_name}",
        {
            "method": "POST",
            "headers": {
                "Content-Type": "application/json",
                "Authorization": f"Bearer {token}" if token else ""
            },
            "body": JSON.stringify({"args": args})
        }
    );

    if not response.ok {
        error_text = await response.text();
        raise Exception(f"Function {function_name} failed: {error_text}");
    }

    data = JSON.parse(await response.text());
    return data.get("result");
}

# Authentication helpers
async def jacSignup(username: str, password: str) -> dict {
    response = await fetch(
        "/user/create",
        {
            "method": "POST",
            "headers": {"Content-Type": "application/json"},
            "body": JSON.stringify({"username": username, "password": password})
        }
    );

    if response.ok {
        data = JSON.parse(await response.text());
        token = data.get("token");
        if token {
            __setLocalStorage("jac_token", token);
            return {"success": True, "token": token, "username": username};
        }
        return {"success": False, "error": "No token received"};
    } else {
        error_text = await response.text();
        try {
            error_data = JSON.parse(error_text);
            return {"success": False, "error": error_data.get("error", "Signup failed")};
        } except Exception {
            return {"success": False, "error": error_text};
        }
    }
}

async def jacLogin(username: str, password: str) -> bool {
    response = await fetch(
        "/user/login",
        {
            "method": "POST",
            "headers": {"Content-Type": "application/json"},
            "body": JSON.stringify({"username": username, "password": password})
        }
    );

    if response.ok {
        data = JSON.parse(await response.text());
        token = data.get("token");
        if token {
            __setLocalStorage("jac_token", token);
            return True;
        }
    }
    return False;
}

def jacLogout() -> None {
    __removeLocalStorage("jac_token");
}

def jacIsLoggedIn() -> bool {
    token = __getLocalStorage("jac_token");
    return token != None and token != "";
}

# Browser API shims
def __getLocalStorage(key: str) -> str {
    storage = globalThis.localStorage;
    return storage.getItem(key) if storage else "";
}

def __setLocalStorage(key: str, value: str) -> None {
    storage = globalThis.localStorage;
    if storage {
        storage.setItem(key, value);
    }
}

def __removeLocalStorage(key: str) -> None {
    storage = globalThis.localStorage;
    if storage {
        storage.removeItem(key);
    }
}
}