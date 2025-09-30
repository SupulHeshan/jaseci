import from byllm { Model }

glob llm: Model = Model("gpt-4o");

node VehicleShowroom {
    can show_vehicles with showroom_visitor entry {
        print("🚗 Welcome to the Vehicle Showroom! Here are the vehicles available:");
        # aaa = visit_by(llm, visitor, self, [self -->]);
        visit [-->] by llm();
        print("🏁 End of the vehicle list.");
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

node ThreeWheeler {
    can act with showroom_visitor entry {
        print("🛺 Three-Wheeler: A compact and efficient vehicle for city travel.");
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
        print("🛎️ Visitor: Entering the showroom...");
        # visit [-->] by llm();
        visit [-->];
    }
}

with entry {
    show_room = root ++> VehicleShowroom();
    show_room ++> Car();
    show_room ++> Bike();
    show_room ++> Van();
    show_room ++> ThreeWheeler();

    showroom_visitor([2, 3]) spawn root;
}




# def say_hello(name: str) -> str by llm();

# with entry {
#     say_hello("Malitha");
# }