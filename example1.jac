import from byllm.llm { Model }

glob llm = Model("gpt-4o");

node VehicleShowroom {
    can show_vehicles with showroom_visitor entry {
        print("Welcome to the Vehicle Showroom! Here are the vehicles available:\n");
        visit [-->] by llm();
    }
}

node Car {
    can act with showroom_visitor entry {
        print("🚙 Car: A sleek sedan with modern features.");
    }
}

node Bike {
    can act with showroom_visitor entry {
        print("🚲 Bike: A sporty mountain bike perfect for off-road adventures.");
    }
}

node Van {
    can act with showroom_visitor entry {
        print("🚚 Van: A spacious van ideal for family trips.");
    }
}

walker showroom_visitor {
    has vehicle_wheel_number: list[int];

    can visit_showroom with `root entry {
        print("Visitor: Entering the showroom...");
        visit [-->];
    }
}

with entry {
    show_room = root ++> VehicleShowroom();
    show_room ++> Car();
    show_room ++> Bike();
    show_room ++> Van();

    showroom_visitor([2, 4]) spawn root;
}
