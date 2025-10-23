#!/usr/bin/env python3
"""
Demo script to show BEFORE and AFTER the API key sanitization fix.
This demonstrates the security vulnerability and how it was fixed.
"""

import io
import sys
from byllm.llm_connector import LiteLLMConnector
from byllm.mtir import MTIR


def simulate_vulnerable_version():
    """Simulate the BEFORE state - logging params WITHOUT sanitization."""
    print("=" * 80)
    print("BEFORE FIX (VULNERABLE):")
    print("=" * 80)

    connector = LiteLLMConnector(
        proxy=False,
        model_name="gpt-4",
        api_key="sk-SUPER-SECRET-KEY-abc123xyz",
        verbose=True
    )

    params = {
        "model": "gpt-4",
        "api_key": "sk-SUPER-SECRET-KEY-abc123xyz",
        "messages": [{"role": "user", "content": "Hello"}],
        "temperature": 0.7
    }

    captured_output = io.StringIO()
    sys.stdout = captured_output

    # WITHOUT sanitization (vulnerable code)
    connector.log_info(f"Calling LLM: {connector.model_name} with params:\n{params}")

    sys.stdout = sys.__stdout__
    output = captured_output.getvalue()

    print(output)

    if "sk-SUPER-SECRET-KEY-abc123xyz" in output:
        print("🚨 SECURITY ISSUE: API KEY IS EXPOSED IN THE OUTPUT! 🚨")
    print()


def simulate_fixed_version():
    """Simulate the AFTER state - logging params WITH sanitization."""
    print("=" * 80)
    print("AFTER FIX (SECURE):")
    print("=" * 80)

    connector = LiteLLMConnector(
        proxy=False,
        model_name="gpt-4",
        api_key="sk-SUPER-SECRET-KEY-abc123xyz",
        verbose=True
    )

    params = {
        "model": "gpt-4",
        "api_key": "sk-SUPER-SECRET-KEY-abc123xyz",
        "messages": [{"role": "user", "content": "Hello"}],
        "temperature": 0.7
    }

    captured_output = io.StringIO()
    sys.stdout = captured_output

    # WITH sanitization (fixed code)
    connector.log_info(
        f"Calling LLM: {connector.model_name} with params:\n{connector.sanitize_params(params)}"
    )

    sys.stdout = sys.__stdout__
    output = captured_output.getvalue()

    print(output)

    if "sk-SUPER-SECRET-KEY-abc123xyz" not in output:
        print("✅ SECURE: API key is properly redacted!")
    if "***REDACTED***" in output:
        print("✅ Placeholder '***REDACTED***' is shown instead")
    print()


if __name__ == "__main__":
    print("\n")
    print("╔═══════════════════════════════════════════════════════════════════╗")
    print("║        API KEY SANITIZATION - BEFORE & AFTER DEMONSTRATION        ║")
    print("╚═══════════════════════════════════════════════════════════════════╝")
    print("\n")

    simulate_vulnerable_version()
    simulate_fixed_version()

    print("=" * 80)
    print("SUMMARY:")
    print("=" * 80)
    print("The fix adds a sanitize_params() method that redacts sensitive")
    print("information before logging, preventing API key exposure in verbose mode.")
    print("=" * 80)
