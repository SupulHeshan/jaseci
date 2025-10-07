import from byllm { Model }

glob llm: Model = Model("gpt-4o");

node VehicleShowroom {
    can show_vehicles with showroom_visitor entry {
        print("Welcome to the Vehicle Showroom! Here are the vehicles available:\n");
        visit [-->(`?Car)] by llm();
    }
}

node Car {
    has color: str;
    can act with showroom_visitor entry {
        print("🚙 Car: A sleek sedan with modern features.");
    }
}

node Bike {
    has color: str;
    can act with showroom_visitor entry {
        print("🚲 Bike: A sporty mountain bike perfect for off-road adventures.");
    }
}

walker showroom_visitor {
    has expected_color: list[str];

    can visit_showroom with `root entry {
        print("Visitor: Entering the showroom...");
        visit [-->];
    }
}

with entry {
    show_room = root ++> VehicleShowroom();
    show_room ++> Car("Red");
    show_room ++> Car("Blue");
    show_room ++> Car("Black");
    show_room ++> Bike("Green");
    show_room ++> Bike("Blue");

    showroom_visitor(["Blue"]) spawn root;
}