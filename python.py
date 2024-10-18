def extract_calibration_values(filename):
    total_sum = 0
    
    with open(filename, 'r') as file:
        for line in file:
            line = line.strip()  # Remove any leading/trailing whitespace
            if not line:
                continue  # Skip empty lines
            
            # Find the first and last digit in the line
            first_digit = None
            last_digit = None
            
            for char in line:
                if char.isdigit():
                    if first_digit is None:
                        first_digit = char
                    last_digit = char  # Update last_digit every time a digit is found
            
            # If both digits were found, calculate the value
            if first_digit is not None and last_digit is not None:
                calibration_value = int(first_digit + last_digit)
                total_sum += calibration_value
    
    return total_sum

# Specify the input file
input_file = 'input.txt'
result = extract_calibration_values(input_file)
print(f"The sum of all calibration values is: {result}")
