node Todo {
    has text: str;
    has done: bool = False;
}

walker create_todo {
    can create with `root entry {
        new_todo = here ++> Todo(text=visitor.text);
        report new_todo;
    }
}

walker toggle_todo {
    can toggle with Todo entry {
        here.done = not here.done;
        report here;
    }
}

walker delete_todo {
    can delete with Todo entry {
        del here;
        report {"success": True};
    }
}

walker read_todos {
    can read with `root entry {
        visit [-->(`?Todo)];
    }
    can report_todos with Todo entry {
        report here;
    }
}
