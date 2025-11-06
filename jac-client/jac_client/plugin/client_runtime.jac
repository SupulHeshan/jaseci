"""Client-side runtime for Jac JSX and walker interactions."""

cl import from 'react' {* as React}
cl {
# JSX factory function - uses React.createElement
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
}