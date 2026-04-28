# 🐍 Python — Cheat Sheet
*Versatile, readable programming language for scripting, web, data science, and automation.*

---

## 📦 Data Types & Variables
*Basic data types and variable assignment.*

```python
x = 10  # Integer
y = 3.14  # Float
name = "Alice"  # String (immutable)
is_valid = True  # Boolean
nothing = None  # None type

# Type conversion
int("42")  # Convert to integer
float("3.14")  # Convert to float
str(42)  # Convert to string
bool(0)  # Convert to boolean (0 is False)

# Check type
type(x)  # Get type of variable
isinstance(x, int)  # Check if variable is integer
```

---

## 🔤 Strings
*String creation, manipulation, and formatting.*

```python
# String creation
s1 = "double quotes"
s2 = 'single quotes'
s3 = """multi
line
string"""  # Multi-line string

# Indexing and slicing
s = "hello"
s[0]  # "h" - first character
s[-1]  # "o" - last character
s[1:4]  # "ell" - slice from index 1 to 3
s[:3]  # "hel" - slice from start to index 2
s[::2]  # "hlo" - every 2nd character

# String methods
s.upper()  # Convert to uppercase
s.lower()  # Convert to lowercase
s.strip()  # Remove leading/trailing whitespace
s.split(",")  # Split by delimiter
",".join(["a", "b", "c"])  # Join list with delimiter
s.replace("old", "new")  # Replace substring
s.startswith("he")  # Check prefix
s.endswith("lo")  # Check suffix
s.find("ll")  # Find index of substring

# String formatting
f"Name: {name}, Age: {age}"  # f-string (modern)
"Name: {}, Age: {}".format(name, age)  # format() method
"Name: %s, Age: %d" % (name, age)  # % formatting (older)
```

---

## 📋 Lists & Dicts
*Collections for storing and organizing data.*

```python
# Lists (mutable, ordered)
nums = [1, 2, 3, 4, 5]  # Create list
nums.append(6)  # Add to end
nums.insert(0, 0)  # Insert at index
nums.remove(3)  # Remove by value
nums.pop()  # Remove and return last item
len(nums)  # Get length
nums[0]  # Access by index
nums[-1]  # Last item
nums[1:3]  # Slice from index 1 to 2
nums.sort()  # Sort in place
sorted(nums)  # Return sorted copy

# Dictionaries (mutable, key-value pairs)
person = {"name": "Alice", "age": 30}  # Create dict
person["city"] = "NYC"  # Add/update key
del person["age"]  # Delete key
person.get("name")  # Safe get (returns None if missing)
person.get("job", "Unknown")  # Get with default
person.keys()  # Get all keys
person.values()  # Get all values
person.items()  # Get key-value pairs
"name" in person  # Check if key exists
len(person)  # Get number of items

# Iteration
for num in nums:  # Iterate over list
    print(num)

for key, value in person.items():  # Iterate over dict
    print(f"{key}: {value}")

for i, num in enumerate(nums):  # Get index and value
    print(f"{i}: {num}")
```

---

## 🎛️ Control Flow
*Conditional statements and branching.*

```python
# if/elif/else
if x > 10:  # Condition
    print("x is large")
elif x > 5:  # Else if
    print("x is medium")
else:  # Default case
    print("x is small")

# Comparison operators
x == y  # Equal to
x != y  # Not equal to
x > y  # Greater than
x >= y  # Greater than or equal
x < y  # Less than
x <= y  # Less than or equal

# Logical operators
x > 5 and x < 10  # Both conditions true
x < 5 or x > 10  # At least one condition true
not (x == 5)  # Negate condition

# Ternary operator
"yes" if x > 5 else "no"  # Conditional expression
```

---

## 🔄 Loops
*Iterate over sequences and repeat code blocks.*

```python
# for loop
for i in range(5):  # 0, 1, 2, 3, 4
    print(i)

for i in range(1, 6):  # 1, 2, 3, 4, 5
    print(i)

for i in range(0, 10, 2):  # Step by 2: 0, 2, 4, 6, 8
    print(i)

for item in items:  # Iterate over list
    print(item)

# while loop
while x < 10:  # Repeat while condition is true
    print(x)
    x += 1

# Loop control
for i in range(10):
    if i == 3:
        continue  # Skip to next iteration
    if i == 7:
        break  # Exit loop
    print(i)

# Loop with else
for i in range(5):
    print(i)
else:  # Executes if loop completes normally (no break)
    print("Loop finished")
```

---

## 🔧 Functions
*Define reusable blocks of code.*

```python
# Basic function
def greet(name):  # Parameter
    return f"Hello, {name}"  # Return value

greet("Alice")  # Function call

# Default parameters
def greet(name, greeting="Hello"):  # Default argument
    return f"{greeting}, {name}"

greet("Alice")  # Uses default
greet("Alice", "Hi")  # Override default

# Variable number of arguments
def sum_all(*args):  # *args captures multiple arguments as tuple
    return sum(args)

sum_all(1, 2, 3, 4)  # 10

# Keyword arguments
def build_profile(name, **kwargs):  # **kwargs captures keyword arguments as dict
    profile = {"name": name, **kwargs}
    return profile

build_profile("Alice", age=30, city="NYC")  # {'name': 'Alice', 'age': 30, 'city': 'NYC'}

# Lambda (anonymous function)
square = lambda x: x ** 2  # Inline function
result = square(5)  # 25
nums = [1, 2, 3, 4]
squared = list(map(lambda x: x ** 2, nums))  # [1, 4, 9, 16]
```

---

## 📁 File I/O
*Read and write files.*

```python
# Read file
with open("file.txt", "r") as f:  # Open in read mode, auto-close
    content = f.read()  # Read entire file

with open("file.txt", "r") as f:
    lines = f.readlines()  # Read as list of lines

with open("file.txt", "r") as f:
    for line in f:  # Iterate over lines
        print(line.strip())

# Write file
with open("file.txt", "w") as f:  # Open in write mode (overwrites)
    f.write("Hello\n")  # Write string
    f.writelines(["line1\n", "line2\n"])  # Write list of lines

# Append to file
with open("file.txt", "a") as f:  # Append mode
    f.write("New line\n")

# JSON
import json
data = {"name": "Alice", "age": 30}
json.dumps(data)  # Convert to JSON string
json.dump(data, f)  # Write JSON to file
loaded = json.loads(json_string)  # Parse JSON string
loaded = json.load(f)  # Read JSON from file
```

---

## ⚠️ Error Handling
*Catch and handle exceptions.*

```python
# try/except/finally
try:
    result = 10 / 0  # May raise exception
except ZeroDivisionError:  # Catch specific exception
    print("Cannot divide by zero")
except (ValueError, TypeError):  # Catch multiple exceptions
    print("Invalid input")
except Exception as e:  # Catch all exceptions
    print(f"Error: {e}")
finally:  # Always executes
    print("Cleanup code")

# Raise exception
if x < 0:
    raise ValueError("x must be positive")  # Raise custom exception

# Custom exception
class CustomError(Exception):  # Define custom exception
    pass

raise CustomError("Something went wrong")
```

---

## 🎯 Comprehensions
*Create lists, dicts, and sets concisely.*

```python
# List comprehension
squares = [x ** 2 for x in range(5)]  # [0, 1, 4, 9, 16]
evens = [x for x in range(10) if x % 2 == 0]  # [0, 2, 4, 6, 8]
pairs = [(x, y) for x in range(3) for y in range(2)]  # Nested loop

# Dictionary comprehension
squares_dict = {x: x ** 2 for x in range(5)}  # {0: 0, 1: 1, 2: 4, 3: 9, 4: 16}
swapped = {v: k for k, v in original_dict.items()}  # Swap keys and values

# Set comprehension
unique_squares = {x ** 2 for x in [1, 2, 2, 3, 3]}  # {1, 4, 9}

# Generator expression (lazy evaluation)
gen = (x ** 2 for x in range(1000000))  # Doesn't compute until needed
next(gen)  # Get next value
```

---

## 📚 Modules & Imports
*Import and use external code modules.*

```python
import math  # Import entire module
math.sqrt(16)  # Use module function

from math import sqrt  # Import specific function
sqrt(16)  # Use function directly

from math import sqrt as square_root  # Alias
square_root(16)

from math import *  # Import all (discouraged)
sqrt(16)

# Check if script is run directly
if __name__ == "__main__":  # True only when script is executed directly
    main()
```

---

## 🔨 Useful stdlib
*Common standard library modules.*

```python
# os - Operating system functions
import os
os.getcwd()  # Get current directory
os.listdir(".")  # List files
os.path.exists("file.txt")  # Check if file exists
os.path.join("dir", "file.txt")  # Build path
os.remove("file.txt")  # Delete file
os.environ["HOME"]  # Get environment variable

# sys - System functions
import sys
sys.argv  # Command-line arguments
sys.exit(0)  # Exit script
sys.stdout.write("text")  # Write to stdout

# json - JSON parsing
import json
json.dumps({"key": "value"})  # Convert to JSON
json.loads('{"key": "value"}')  # Parse JSON

# re - Regular expressions
import re
re.search(r"\d+", "abc123")  # Search for pattern
re.findall(r"\w+", "hello world")  # Find all matches
re.sub(r"\d+", "X", "abc123def456")  # Replace pattern
re.match(r"^\d+", "123abc")  # Match at start

# pathlib - Path operations
from pathlib import Path
p = Path("file.txt")  # Create path object
p.exists()  # Check if exists
p.read_text()  # Read file
p.write_text("content")  # Write file
p.parent  # Parent directory
p.name  # Filename
p.stem  # Filename without extension
```
