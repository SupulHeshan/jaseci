#!/bin/bash
# Quick test runner - shows only pass/fail summary

export PYTHONPATH=/home/mgtm/jaseci/jac
cd "$(dirname "$0")"

echo "Running JavaScript Parser Tests..."
echo "=================================="
echo ""

passed=0
failed=0

for file in test_cases/*.js; do
    filename=$(basename "$file")
    if python3 parser.py "$file" > /dev/null 2>&1; then
        echo "✅ $filename"
        ((passed++))
    else
        echo "❌ $filename"
        ((failed++))
    fi
done

echo ""
echo "=================================="
echo "Results: $passed passed, $failed failed"
echo "=================================="
