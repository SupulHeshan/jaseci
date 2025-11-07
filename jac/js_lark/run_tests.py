#!/usr/bin/env python3
"""
Test runner for JavaScript parser
Tests all files in test_cases directory
"""

import os
import json
from pathlib import Path
from parser import parse_javascript

def test_file(filepath):
    """Test a single JavaScript file"""
    filename = os.path.basename(filepath)
    print(f"\n{'='*70}")
    print(f"Testing: {filename}")
    print('='*70)
    
    try:
        with open(filepath, 'r') as f:
            code = f.read()
        
        # Parse the code
        ast = parse_javascript(code)
        
        # Check if it's a valid AST
        if isinstance(ast, dict) and ast.get("type") == "Program":
            print(f"✅ PASS - Successfully parsed")
            print(f"   Statements: {len(ast.get('body', []))}")
            
            # Show first statement type as sample
            if ast.get('body'):
                first_stmt = ast['body'][0]
                print(f"   First statement type: {first_stmt.get('type', 'Unknown')}")
            
            return True, None
        else:
            print(f"❌ FAIL - Invalid AST structure")
            return False, "Invalid AST"
            
    except Exception as e:
        print(f"❌ FAIL - Parse error: {str(e)}")
        return False, str(e)

def main():
    """Run all tests"""
    test_dir = Path(__file__).parent / "test_cases"
    
    if not test_dir.exists():
        print(f"Error: Test directory not found: {test_dir}")
        return
    
    # Get all .js files sorted
    test_files = sorted(test_dir.glob("*.js"))
    
    if not test_files:
        print(f"No test files found in {test_dir}")
        return
    
    print(f"\n{'='*70}")
    print(f"JavaScript Parser Test Suite")
    print(f"Running {len(test_files)} tests")
    print('='*70)
    
    results = []
    for filepath in test_files:
        passed, error = test_file(filepath)
        results.append((filepath.name, passed, error))
    
    # Summary
    print(f"\n\n{'='*70}")
    print("TEST SUMMARY")
    print('='*70)
    
    passed = sum(1 for _, p, _ in results if p)
    failed = len(results) - passed
    
    print(f"\nTotal: {len(results)}")
    print(f"✅ Passed: {passed}")
    print(f"❌ Failed: {failed}")
    
    if failed > 0:
        print(f"\nFailed tests:")
        for name, p, error in results:
            if not p:
                print(f"  - {name}: {error}")
    
    print(f"\n{'='*70}")
    
    # Return exit code
    return 0 if failed == 0 else 1

if __name__ == "__main__":
    exit(main())
