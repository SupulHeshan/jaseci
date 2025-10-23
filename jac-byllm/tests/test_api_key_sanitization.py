"""Test API key sanitization in verbose logging."""

import io
import os
import sys
import unittest

from jaclang import JacMachineInterface as Jac
from jaclang.utils.test import TestCase

from byllm.llm_connector import LiteLLMConnector

# Import the jac_import function from JacMachineInterface
jac_import = Jac.jac_import


class TestAPIKeySanitization(unittest.TestCase):
    """Test that API keys are properly sanitized in logs."""

    def test_sanitize_params_redacts_api_key(self) -> None:
        """Test that sanitize_params properly redacts API keys."""
        connector = LiteLLMConnector(
            proxy=False,
            model_name="gpt-4",
            api_key="sk-1234567890abcdef",
            verbose=True
        )

        params = {
            "model": "gpt-4",
            "api_key": "sk-1234567890abcdef",
            "messages": [{"role": "user", "content": "test"}],
            "temperature": 0.7
        }

        sanitized = connector.sanitize_params(params)

        # Verify the API key is redacted
        self.assertEqual(sanitized["api_key"], "***REDACTED***")
        # Verify other params are preserved
        self.assertEqual(sanitized["model"], "gpt-4")
        self.assertEqual(sanitized["temperature"], 0.7)
        # Verify original params are unchanged
        self.assertEqual(params["api_key"], "sk-1234567890abcdef")

    def test_verbose_logging_does_not_expose_api_key(self) -> None:
        """Test that verbose logging does not expose the actual API key."""
        connector = LiteLLMConnector(
            proxy=False,
            model_name="gpt-4",
            api_key="sk-secret-key-12345",
            verbose=True
        )

        # Capture stdout
        captured_output = io.StringIO()
        sys.stdout = captured_output

        # Log some params
        connector.log_info(
            f"Calling LLM: {connector.model_name} with params:\n"
            f"{connector.sanitize_params({'api_key': 'sk-secret-key-12345', 'model': 'gpt-4'})}"
        )

        sys.stdout = sys.__stdout__
        stdout_value = captured_output.getvalue()

        # Verify the actual API key is NOT in the output
        self.assertNotIn("sk-secret-key-12345", stdout_value)
        # Verify the redacted placeholder IS in the output
        self.assertIn("***REDACTED***", stdout_value)
        # Verify the model name is still present
        self.assertIn("gpt-4", stdout_value)

    def test_sanitize_params_handles_none_api_key(self) -> None:
        """Test that sanitize_params handles None API keys gracefully."""
        connector = LiteLLMConnector(
            proxy=False,
            model_name="gpt-4",
            verbose=True
        )

        params = {
            "model": "gpt-4",
            "api_key": None,
            "messages": []
        }

        sanitized = connector.sanitize_params(params)

        # Should not crash, None should remain None
        self.assertIsNone(sanitized["api_key"])


class TestAPIKeySanitizationIntegration(TestCase):
    """Integration test that runs actual Jac programs with verbose logging."""

    def test_verbose_jac_program_redacts_api_key(self) -> None:
        """Test that running a Jac program with verbose=True redacts API keys in output."""
        # Capture stdout
        captured_output = io.StringIO()
        sys.stdout = captured_output

        # Run the Jac program with verbose mode enabled
        # This will fail due to invalid API key, but should log params first
        try:
            jac_import("verbose_test", base_path=self.fixture_abs_path("./"))
        except Exception:
            # Expected to fail, we just want to capture the verbose logging
            pass

        # Restore stdout
        sys.stdout = sys.__stdout__
        stdout_value = captured_output.getvalue()

        # The fake API key we used in the fixture
        fake_api_key = "sk-test-SUPER-SECRET-KEY-1234567890abcdef"

        # CRITICAL: Verify the actual API key is NOT exposed in the output
        self.assertNotIn(
            fake_api_key,
            stdout_value,
            f"SECURITY ISSUE: API key '{fake_api_key}' was exposed in verbose output!\n"
            f"Output was:\n{stdout_value[:500]}"
        )

        # Verify the redacted placeholder IS present (proving verbose logging happened)
        self.assertIn(
            "***REDACTED***",
            stdout_value,
            f"Expected to see ***REDACTED*** placeholder in verbose output.\n"
            f"Output was:\n{stdout_value[:500]}"
        )

        # Verify verbose logging shows we're calling the LLM
        self.assertIn(
            "Calling LLM:",
            stdout_value,
            f"Expected to see 'Calling LLM:' in verbose output.\n"
            f"Output was:\n{stdout_value[:500]}"
        )


if __name__ == "__main__":
    unittest.main()
