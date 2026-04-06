#!/usr/bin/env python3

import subprocess
import json
import re
import os
import base64
import secrets
import hashlib
from datetime import datetime
from getpass import getpass

# ANSI color codes
GREEN = '\033[92m'
RED = '\033[91m'
RESET = '\033[0m'
BOLD = '\033[1m'

def generate_key(password, salt=None):
    """Generate encryption key from password using built-in libraries"""
    if salt is None:
        salt = secrets.token_bytes(16)
    # Use SHA-256 for key derivation
    key = hashlib.pbkdf2_hmac(
        'sha256',
        password.encode(),
        salt,
        100000  # Number of iterations
    )
    return key, salt

def encrypt_data(data, password):
    """Encrypt data using XOR with key"""
    try:
        # Generate key and salt
        key, salt = generate_key(password)
        
        # Convert data to bytes
        data_bytes = data.encode()
        
        # XOR encryption
        encrypted = bytearray()
        for i, byte in enumerate(data_bytes):
            key_byte = key[i % len(key)]
            encrypted.append(byte ^ key_byte)
        
        # Combine salt and encrypted data
        final_data = salt + bytes(encrypted)
        
        # Base64 encode for safe storage
        encoded_data = base64.b64encode(final_data)
        return encoded_data
            
    except Exception as e:
        print(f"{RED}Error encrypting data: {e}{RESET}")
        return None

def run_verilog_test(test_file):
    """Run a Verilog test file and return its output"""
    try:
        # Compile the test file
        subprocess.run(['iverilog', test_file], check=True)
        
        # Run the compiled output
        result = subprocess.run(['./a.out'], capture_output=True, text=True, check=True)
        return result.stdout
    except subprocess.CalledProcessError as e:
        print(f"{RED}Error running {test_file}: {e}{RESET}")
        return None

def parse_test_output(output):
    """Parse the test output to extract test case results"""
    results = {}
    # Match pattern: TC1: a=0 b=0 => sum=0 cout=0
    pattern = r'TC(\d+):\s*(.*?)\s*=>\s*(.*?)$'
    
    for line in output.split('\n'):
        if line.strip():
            match = re.match(pattern, line)
            if match:
                tc_num = int(match.group(1))
                inputs = match.group(2).strip()
                outputs = match.group(3).strip()
                results[tc_num] = {'inputs': inputs, 'outputs': outputs}
    
    return results

def load_test_cases():
    """Load test cases from test_cases.json"""
    try:
        with open('DO_NOT_OPEN/test_cases.json', 'r') as f:
            return json.load(f)
    except FileNotFoundError:
        print("Error: test_cases.json not found")
        return None
    except json.JSONDecodeError:
        print("Error: Invalid JSON in test_cases.json")
        return None

def normalize_binary(value):
    """Convert binary string with or without 0b prefix to integer"""
    if isinstance(value, str):
        if value.startswith('0b'):
            return value[2:]  # Return binary string without prefix
        return value
    return str(value)

def extract_value(text, key, module_type=None):
    """Extract value for a specific key from text output"""
    # Try both uppercase and lowercase versions of the key
    keys_to_try = [key.upper(), key.lower()]
    
    for k in keys_to_try:
        # For carry-look-ahead adders
        if module_type and 'carry_look_ahead' in module_type:
            # For multi-bit values (e.g., A=0000, Sum=1111)
            pattern = rf'{k}=([01]+)'
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                return match.group(1)
            
            # For single-bit values (e.g., Cin=0)
            pattern = rf'\b{k}=([01])\b'
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                return match.group(1)
        else:
            # For other modules
            # For multi-bit values
            pattern = rf'{k}=([01]+)'
            match = re.search(pattern, text)
            if match:
                return match.group(1)
            
            # For single-bit values
            pattern = rf'{k}=(\d)'
            match = re.search(pattern, text)
            if match:
                return match.group(1)
    
    return None

def compare_binary_strings(expected, actual):
    """Compare two binary strings, ignoring leading zeros"""
    if expected is None or actual is None:
        return False
    # Remove leading zeros from both strings
    expected = expected.lstrip('0') or '0'
    actual = actual.lstrip('0') or '0'
    return expected == actual

def compare_results(test_output, expected_results, module_name):
    """Compare test output with expected results"""
    print(f"\nTesting {module_name}:")
    print("=" * 50)
    
    all_passed = True
    for tc_num, result in test_output.items():
        # Get expected result from test_cases.json
        expected = expected_results.get(f"testcase-{tc_num}")
        if not expected:
            print(f"{RED}Warning: No expected result found for test case {tc_num}{RESET}")
            continue
            
        # Parse inputs and outputs
        inputs = result['inputs']
        outputs = result['outputs']
        
        # Compare with expected values
        passed = True
        for key, value in expected.items():
            expected_val = normalize_binary(value)
            
            if key.upper() in ['A', 'B', 'CIN'] or key.lower() in ['a', 'b', 'cin']:
                actual_val = extract_value(inputs, key, module_name)
                if not compare_binary_strings(expected_val, actual_val):
                    passed = False
                    print(f"{RED}TC{tc_num} failed: Input {key}={value} (expected) != {actual_val} (actual){RESET}")
            elif key.upper() in ['SUM', 'COUT', 'S'] or key.lower() in ['sum', 'cout', 's']:
                actual_val = extract_value(outputs, key, module_name)
                if not compare_binary_strings(expected_val, actual_val):
                    passed = False
                    print(f"{RED}TC{tc_num} failed: Output {key}={value} (expected) != {actual_val} (actual){RESET}")
        
        if passed:
            print(f"{GREEN}TC{tc_num}: PASSED{RESET}")
        else:
            print(f"{RED}TC{tc_num}: FAILED{RESET}")
            all_passed = False
    
    return all_passed

def main():
    # Create results directory if it doesn't exist
    os.makedirs('test_results', exist_ok=True)
    
    # Ask for BITS ID
    bits_id = input("Enter your BITS ID: ").strip()
    if not bits_id:
        print(f"{RED}Error: BITS ID cannot be empty{RESET}")
        return
    
    # Use default password
    password = "tanish"
    
    # Generate timestamp for the log file
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    log_file = f'test_results/{bits_id}_test_summary_{timestamp}.enc'
    
    # Load test cases
    test_cases = load_test_cases()
    if not test_cases:
        return
    
    # List of test files and their corresponding module names
    test_files = [
        ('DO_NOT_OPEN/test_half_adder.v', 'half_adder.v'),
        ('DO_NOT_OPEN/test_full_adder.v', 'full_adder.v'),
        ('DO_NOT_OPEN/test_carry_look_ahead_4_bit_adder.v', 'carry_look_ahead_4_bit_adder.v'),
        ('DO_NOT_OPEN/test_carry_look_ahead_5_bit_adder.v', 'carry_look_ahead_5_bit_adder.v'),
        ('DO_NOT_OPEN/test_wallace_tree_adder.v', 'wallace_tree_adder.v')
    ]
    
    # Prepare the output content
    output_content = "===== Verilog Test Results =====\n"
    output_content += f"Run at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n"
    output_content += "=" * 50 + "\n\n"
    
    total_passed = 0
    total_tests = len(test_files)
    
    for test_file, module_file in test_files:
        print(f"\n{BOLD}Running tests for {module_file}...{RESET}")
        output_content += f"\nTesting {module_file}:\n"
        output_content += "-" * len(module_file) + "\n"
        
        # Run the test
        output = run_verilog_test(test_file)
        if not output:
            print(f"{RED}Failed to run {test_file}{RESET}")
            output_content += f"Failed to run {test_file}\n"
            continue
        
        # Parse the output
        test_results = parse_test_output(output)
        
        # Compare with expected results
        expected_results = test_cases.get(module_file, {})
        passed = compare_results(test_results, expected_results, module_file)
        
        # Log results
        if passed:
            total_passed += 1
            output_content += "All test cases passed!\n"
            print(f"\n{GREEN}All test cases passed for {module_file}!{RESET}")
        else:
            output_content += "Some test cases failed!\n"
            print(f"\n{RED}Some test cases failed for {module_file}!{RESET}")
        
        # Log detailed output
        output_content += "\nDetailed output:\n"
        output_content += output
        output_content += "\n"
    
    # Add summary
    output_content += "\n" + "=" * 50 + "\n"
    output_content += "Test Summary:\n"
    output_content += f"Total modules tested: {total_tests}\n"
    output_content += f"Modules passed: {total_passed}\n"
    output_content += f"Modules failed: {total_tests - total_passed}\n"
    output_content += f"Success rate: {(total_passed/total_tests)*100:.1f}%\n"
    
    # Print colored summary
    print(f"\n{BOLD}Test Summary:{RESET}")
    print(f"Total modules tested: {total_tests}")
    print(f"{GREEN}Modules passed: {total_passed}{RESET}")
    print(f"{RED}Modules failed: {total_tests - total_passed}{RESET}")
    success_rate = (total_passed/total_tests)*100
    color = GREEN if success_rate >= 80 else RED
    print(f"Success rate: {color}{success_rate:.1f}%{RESET}")
    
    # Encrypt and save the output
    encrypted_data = encrypt_data(output_content, password)
    if encrypted_data:
        with open(log_file, 'wb') as f:
            f.write(encrypted_data)
        print(f"\n{GREEN}Encrypted results saved to: {log_file}{RESET}")
        print(f"{BOLD}Note: Use decrypt_results.py to decrypt the results{RESET}")
    else:
        print(f"\n{RED}Failed to encrypt results{RESET}")

if __name__ == "__main__":
    main() 