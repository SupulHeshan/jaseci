import from byllm.lib { Model, MockToolCall }
node Calculator {
    def add(num1: int, num2: int) -> int {
        return num1 + num2;
    }

    # Defining the model here cause we need the reference to self.
    def eval_expr(expression: str) -> str by Model(
        model_name="mockllm",
        outputs=[
            MockToolCall(
                tool=self.add,
                args={"num1": 12, "num2": 34}
            ),
            "46"
        ],
        verbose=True,
    )(tools=[self.add]);
}

with entry {
    Calculator().eval_expr("What is 12 + 34?");
}