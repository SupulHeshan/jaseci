





obj Person{
    has name:str;
}


obj Student(Person){
    has student_id:int;
}

with entry{
    Student('Peter', 12345).type;
}