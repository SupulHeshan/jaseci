include walker;

import datetime;
import numpy;
import from sklearn.feature_extraction.text { TfidfVectorizer }
import from sklearn.metrics.pairwise { cosine_similarity }


def search_tweets(query: str, tweet:str) -> int;

node Profile {
    has username: str = "";

    can update with update_profile entry;

    can get with get_profile entry;

    can follow with follow_request entry;

    can un_follow with un_follow_request entry;
}

obj TweetInfo {
    has username: str;
    has id: str;
    has content: str;
    has embedding: list;
    has likes: list;
    has comments: list;
}

node Tweet {
    has content: str;
    has embedding: list;
    has created_at: str = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S");

    can update with update_tweet exit;

    can delete with remove_tweet exit;

    can like_tweet with like_tweet entry;

    can remove_like with remove_like entry;

    can comment with comment_tweet entry;

    def get_info()-> TweetInfo;

    can get with load_feed entry;
}

node Comment {
    has content: str;

    can update with update_comment entry;

    can delete with remove_comment entry;
}

edge Follow {}

edge Like {}

edge Post {}

walker visit_profile {
    can visit_profile with `root entry;
}

walker update_profile(visit_profile) {
    has new_username: str;
}

walker get_profile(visit_profile) {}

walker load_user_profiles {
    obj __specs__ {
        static has auth: bool = False;
    }
    can load_profiles with `root entry;

    can report_profiles with exit;
}

walker follow_request {}

walker un_follow_request {}

walker create_tweet(visit_profile) {
    has content: str;

    can tweet with Profile entry;
}

walker update_tweet {
    has updated_content: str;
}

walker remove_tweet {}

walker like_tweet {}

walker remove_like {}

walker comment_tweet {
    has content: str;
}

walker update_comment {
    has updated_content: str;
}

walker remove_comment {}

walker load_feed(visit_profile) {
    has search_query: str = "";
    has results: list = [];

    can load with Profile entry;

    can report_feed with exit;

}

walker search_users {
    has query: str;
    static has users: list = [
        {"username": "alice", "email": "alice@example.com"},
        {"username": "bob", "email": "bob@example.com"}
    ];

    obj __specs__ {
        static has methods: list = ["get"];
        static has as_query: list = ["query"];
        static has auth: bool = False;
    }

    can search_by_name with `root entry{
        for user in self.users {
            if user['username'] == self.query {
                report user;
                return;
            }
        }

        report {
            "error": f"User with username {self.query} not found"
        };
    }
}

# Pages
cl import from react {useState, useEffect}
cl import from "@jac-client/utils" {Router, Routes, Route, Link, Navigate, useNavigate, jacIsLoggedIn, jacLogin, jacSignup, __jacSpawn, jacLogout}

cl import from .store {useBearStore}



cl {
    def flattenReports(raw: any) -> list {
            if not raw {
                return [];
            }
            if Array.isArray(raw) {
                accumulator = [];
                raw.forEach(lambda entry: any -> None {
                    if Array.isArray(entry) {
                        entry.forEach(lambda nested: any -> None {
                            if nested {
                                accumulator.push(nested);
                            }
                        });
                    } elif entry {
                        accumulator.push(entry);
                    }
                });
                return accumulator;
            }
            return [raw];
        }

    async def search_users(query: str) -> any {
        users = [];
        try {
            response = await __jacSpawn("search_users", "",{"query": "alice"});
            users = flattenReports(response.reports) if response.reports else [];
            return users;
        }except Exception as e {
            console.log("Error loading feed:", e);
            return users;
        }
    }

    async  def createTweet(content: str) -> any {
        try {
            response = await __jacSpawn("create_tweet", "",{"content": content});
            return response.reports[0];
        }except Exception as e {
            console.log("Error creating tweet:", e);
            return None;
        }
    }
    def app() -> any {

        async def handleSearch() -> any {
            searchUsers = await search_users("alice");
            console.log("Search Users Result:", searchUsers);

        }

        bearsStore = useBearStore();
        bears = bearsStore["bears"];
        increasePopulation = bearsStore["increasePopulation"];
        removeAllBears = bearsStore["removeAllBears"];

        let [count, setCount] = useState(0);
        useEffect(lambda -> None {
            console.log("Count: ", count);
        }, [count]);

        useEffect(lambda -> None {
           handleSearch();
        }, []);


        return <div>
            <h1 className="text-3xl text-blue-500">Hello, World!</h1>
            <p>Count: {count}</p>
            <button onClick={lambda e: any ->  None {setCount(count + 1);}}>Increment</button>

            <p>Bears: {bears}</p>
            <button onClick={lambda e: any ->  None {increasePopulation();}}>Increase Bears</button>
            <button onClick={lambda e: any ->  None {removeAllBears();}}>Remove All Bears</button>
        </div>;
    }
}
