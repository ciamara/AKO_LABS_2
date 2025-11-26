invalid_byte = b'\xFF' 

file_path = r"C:\Users\kotel\OneDrive\Pulpit\AKO_LAB1\invalid2.txt"

try:
    with open(file_path, 'wb') as f:
        f.write(invalid_byte)
    print(f"File successfully created at: {file_path}")
except Exception as e:
    print(f"An error occurred while writing the file: {e}")