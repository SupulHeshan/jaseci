import from byllm.lib { Model }

# This test uses verbose mode with a fake API key to verify it gets redacted
# We use a real LiteLLM model (gpt-4) which will try to call the API and log params
glob llm = Model(
    model_name="gpt-4",
    api_key="sk-test-SUPER-SECRET-KEY-1234567890abcdef",
    verbose=True,
);

def simple_function(input: str) -> str by llm(temperature=0.7);

with entry {
    try {
        # This will fail because the API key is fake, but it should log params first
        result = simple_function('Say hello');
        print(f"Result: {result}");
    } except Exception as e {
        # Expected to fail with invalid API key
        print(f"Expected API error occurred (this is OK for testing)");
    }
}
