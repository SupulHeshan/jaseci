#!/bin/bash
# Wrapper script for regression testing

export PYTHONPATH=/home/mgtm/jaseci/jac
cd "$(dirname "$0")"

echo "JavaScript Parser - Regression Test Harness"
echo "=========================================="
python3 regression_test.py "$@"
