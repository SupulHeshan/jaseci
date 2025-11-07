#!/usr/bin/env python3
"""
Regression Test Harness for JavaScript Parser
Saves expected outputs and compares against them to detect regressions
"""

import os
import json
import hashlib
from pathlib import Path
from parser import parse_javascript
from datetime import datetime

class TestHarness:
    def __init__(self):
        self.test_dir = Path(__file__).parent / "test_cases"
        self.baseline_dir = Path(__file__).parent / "test_baselines"
        self.baseline_dir.mkdir(exist_ok=True)
        
    def generate_baseline(self, test_file):
        """Generate baseline output for a test file"""
        try:
            with open(test_file, 'r') as f:
                code = f.read()
            
            ast = parse_javascript(code)
            return ast, None
        except Exception as e:
            return None, str(e)
    
    def save_baseline(self, test_name, result, error):
        """Save baseline result to file"""
        baseline_file = self.baseline_dir / f"{test_name}.json"
        
        baseline_data = {
            "test_name": test_name,
            "timestamp": datetime.now().isoformat(),
            "success": error is None,
            "error": error,
            "ast": result,
            "hash": self.compute_hash(result, error)
        }
        
        with open(baseline_file, 'w') as f:
            json.dump(baseline_data, f, indent=2)
    
    def load_baseline(self, test_name):
        """Load baseline result from file"""
        baseline_file = self.baseline_dir / f"{test_name}.json"
        
        if not baseline_file.exists():
            return None
            
        with open(baseline_file, 'r') as f:
            return json.load(f)
    
    def compute_hash(self, ast, error):
        """Compute hash of the result for quick comparison"""
        # For errors, ignore the specific token order in "Expected one of" messages
        # as LARK's ordering can be non-deterministic
        if error:
            # Extract just the core error without token list
            error_lines = error.split('\n')
            core_error = error_lines[0] if error_lines else error
            content = json.dumps({"ast": ast, "error_type": core_error}, sort_keys=True)
        else:
            content = json.dumps({"ast": ast, "error": error}, sort_keys=True)
        return hashlib.sha256(content.encode()).hexdigest()[:16]
    
    def compare_results(self, baseline, current_ast, current_error):
        """Compare current result with baseline"""
        current_hash = self.compute_hash(current_ast, current_error)
        baseline_hash = baseline.get("hash", "")
        
        if current_hash == baseline_hash:
            return True, "MATCH", None
        
        # Detailed comparison
        differences = []
        
        # Check success/failure status
        current_success = current_error is None
        baseline_success = baseline.get("success", False)
        
        if current_success != baseline_success:
            differences.append(f"Status changed: baseline {'PASS' if baseline_success else 'FAIL'} -> current {'PASS' if current_success else 'FAIL'}")
        
        # Check error messages
        if current_error != baseline.get("error"):
            differences.append(f"Error changed: '{baseline.get('error')}' -> '{current_error}'")
        
        # Check AST structure (basic comparison)
        if current_ast != baseline.get("ast"):
            differences.append("AST structure differs")
        
        return False, "DIFFER", differences
    
    def run_test(self, test_file):
        """Run a single test and compare with baseline"""
        test_name = test_file.stem
        
        # Generate current result
        current_ast, current_error = self.generate_baseline(test_file)
        
        # Load baseline
        baseline = self.load_baseline(test_name)
        
        if baseline is None:
            # No baseline exists, create it
            self.save_baseline(test_name, current_ast, current_error)
            return {
                "test": test_name,
                "status": "NEW_BASELINE",
                "success": current_error is None,
                "message": "Created new baseline"
            }
        
        # Compare with baseline
        matches, status, differences = self.compare_results(baseline, current_ast, current_error)
        
        result = {
            "test": test_name,
            "status": status,
            "success": current_error is None,
            "baseline_success": baseline.get("success", False),
            "differences": differences
        }
        
        return result
    
    def update_baseline(self, test_name):
        """Update baseline for a specific test"""
        test_file = self.test_dir / f"{test_name}.js"
        if not test_file.exists():
            print(f"❌ Test file not found: {test_file}")
            return False
            
        ast, error = self.generate_baseline(test_file)
        self.save_baseline(test_name, ast, error)
        print(f"✅ Updated baseline for {test_name}")
        return True
    
    def run_all_tests(self):
        """Run all tests and compare with baselines"""
        test_files = sorted(self.test_dir.glob("*.js"))
        
        if not test_files:
            print(f"No test files found in {self.test_dir}")
            return False
        
        print(f"\n{'='*70}")
        print(f"Regression Test Harness")
        print(f"Running {len(test_files)} tests against baselines")
        print('='*70)
        
        results = []
        
        for test_file in test_files:
            result = self.run_test(test_file)
            results.append(result)
            
            # Print result
            test = result["test"]
            status = result["status"]
            
            if status == "MATCH":
                print(f"✅ {test:<25} PASS (matches baseline)")
            elif status == "NEW_BASELINE":
                print(f"🆕 {test:<25} NEW BASELINE")
            elif status == "DIFFER":
                success_symbol = "✅" if result["success"] else "❌"
                baseline_symbol = "✅" if result["baseline_success"] else "❌"
                print(f"⚠️  {test:<25} CHANGED ({baseline_symbol} -> {success_symbol})")
                for diff in result.get("differences", []):
                    print(f"     └─ {diff}")
        
        # Summary
        print(f"\n{'='*70}")
        print("REGRESSION TEST SUMMARY")
        print('='*70)
        
        matches = sum(1 for r in results if r["status"] == "MATCH")
        new_baselines = sum(1 for r in results if r["status"] == "NEW_BASELINE")
        changes = sum(1 for r in results if r["status"] == "DIFFER")
        
        print(f"\nTotal tests: {len(results)}")
        print(f"✅ Matching baselines: {matches}")
        print(f"🆕 New baselines: {new_baselines}")
        print(f"⚠️  Changed results: {changes}")
        
        if changes > 0:
            print(f"\n⚠️  WARNING: {changes} test(s) have different results!")
            print("   Review changes and update baselines if intentional:")
            for r in results:
                if r["status"] == "DIFFER":
                    print(f"     python3 regression_test.py --update {r['test']}")
        
        print(f"\n{'='*70}")
        
        return changes == 0
    
    def show_baseline_info(self):
        """Show information about existing baselines"""
        baselines = list(self.baseline_dir.glob("*.json"))
        
        if not baselines:
            print("No baselines found")
            return
        
        print(f"\n{'='*70}")
        print("BASELINE INFORMATION")
        print('='*70)
        
        for baseline_file in sorted(baselines):
            with open(baseline_file, 'r') as f:
                data = json.load(f)
            
            test_name = data.get("test_name", baseline_file.stem)
            timestamp = data.get("timestamp", "unknown")
            success = data.get("success", False)
            hash_val = data.get("hash", "unknown")
            
            status = "PASS" if success else "FAIL"
            print(f"{test_name:<25} {status:<4} {timestamp[:19]} {hash_val}")

def main():
    import sys
    
    harness = TestHarness()
    
    if len(sys.argv) > 1:
        command = sys.argv[1]
        
        if command == "--update":
            if len(sys.argv) < 3:
                print("Usage: python3 regression_test.py --update <test_name>")
                return 1
            test_name = sys.argv[2]
            success = harness.update_baseline(test_name)
            return 0 if success else 1
            
        elif command == "--update-all":
            # Update all baselines
            test_files = sorted(harness.test_dir.glob("*.js"))
            for test_file in test_files:
                ast, error = harness.generate_baseline(test_file)
                harness.save_baseline(test_file.stem, ast, error)
            print(f"✅ Updated {len(test_files)} baselines")
            return 0
            
        elif command == "--info":
            harness.show_baseline_info()
            return 0
            
        elif command == "--help":
            print("Regression Test Harness Commands:")
            print("  python3 regression_test.py              # Run all tests")
            print("  python3 regression_test.py --update <test>  # Update specific baseline")
            print("  python3 regression_test.py --update-all     # Update all baselines")
            print("  python3 regression_test.py --info           # Show baseline info")
            return 0
    
    # Default: run all tests
    success = harness.run_all_tests()
    return 0 if success else 1

if __name__ == "__main__":
    exit(main())
