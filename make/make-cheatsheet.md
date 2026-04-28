# 🔨 Make — Cheat Sheet
*Build automation tool that executes commands based on file dependencies to compile and manage projects.*

---

## 📋 Makefile Structure
*Basic Makefile organization and syntax.*

```makefile
# Comments start with #
## Multiple # can be used for emphasis

TARGET: DEPENDENCIES  # Target rule: dependencies
	COMMAND  # Commands must start with TAB, not spaces

all: target1 target2  # Default target when running 'make' with no args
## Conventional name for main build target

clean:  # Target with no dependencies
	rm -f *.o  # Remove object files
## Targets with no dependencies always execute

.PHONY: all clean test  # Declare targets as phony (not files)
## Phony targets always execute; not checked against files

# Order matters: targets defined later can reference earlier ones
```

---

## 📦 Variables
*Define and use variables.*

```makefile
VAR = value  # Simple variable assignment
## Evaluated at usage time (deferred expansion)

VAR := value  # Immediate variable assignment
## Evaluated immediately; can't reference vars defined later

VAR ?= default_value  # Conditional assignment (if not set)
## Only assigns if VAR is undefined

VAR += extra  # Append to variable
## Concatenates with space

# Built-in variables
CFLAGS = -Wall -g  # Compiler flags
LDFLAGS = -lm  # Linker flags
CC = gcc  # C compiler
CPPFLAGS = -I/usr/include  # Preprocessor flags

# Using variables
program: main.o utils.o
	$(CC) $(CFLAGS) -o $@ $^  # $(VAR) syntax for substitution
## $@ is target, $^ is all dependencies

# Environment variables
HOME = $(HOME)  # Access shell environment
USER = $(shell whoami)  # Execute command and capture output

# String manipulation
SOURCE = main.c utils.c lib.c
OBJECTS = $(SOURCE:.c=.o)  # Replace .c with .o
## Pattern substitution

basename = $(basename $(1))  # User-defined function (advanced)
```

---

## 🎯 Targets & Dependencies
*Define build targets and their dependencies.*

```makefile
program: main.o utils.o lib.o  # Binary target with object dependencies
	gcc -o program main.o utils.o lib.o
## Target depends on object files

main.o: main.c utils.h  # Object file depends on source and header
	gcc -c main.c
## Header changes trigger recompilation

utils.o: utils.c utils.h lib.h
	gcc -c utils.c

lib.o: lib.c lib.h
	gcc -c lib.c

all: program docs test  # Meta-target with multiple dependencies
## Builds everything when target is requested

install: program  # Install target
	mkdir -p /usr/local/bin
	cp program /usr/local/bin/
## Usually depends on final build target

uninstall:  # Uninstall target
	rm /usr/local/bin/program
## Inverse of install

.PHONY: all install uninstall  # Declare as phony
## Prevents "file already exists" errors
```

---

## 🎪 Phony Targets
*Create targets that don't represent files.*

```makefile
.PHONY: build test clean install  # Declare multiple phony targets
## Make runs these even if files with these names exist

build: all  # Alias for another target
	@echo "Build complete"
## @echo suppresses echoing the command itself

test:  # Test target
	./run_tests.sh
	pytest tests/

coverage:  # Coverage target
	coverage run -m pytest tests/
	coverage report
	coverage html

help:  # Help target
	@echo "Available targets:"
	@echo "  make build    - Build the project"
	@echo "  make test     - Run tests"
	@echo "  make clean    - Remove build artifacts"
## @ suppresses command echo; useful for info output

format:  # Code formatting
	black .
	isort .

lint:  # Linting
	flake8 src/
	pylint src/

docker:  # Docker target
	docker build -t myapp:latest .
	docker run myapp:latest
```

---

## 📐 Pattern Rules
*Use pattern matching for automatic rule generation.*

```makefile
%.o: %.c  # Pattern rule: any .o depends on corresponding .c
	gcc -c $< -o $@
## $< is first dependency; $@ is target; prevents writing rule for each .o

%.o: %.cpp  # Pattern for C++ files
	g++ -c $(CPPFLAGS) $< -o $@

%.html: %.md  # Convert markdown to HTML
	pandoc $< -o $@

%.txt: %.md  # Pattern rule with multiple steps
	pandoc $< --to plain -o $@

# Implicit rules (built-in patterns)
%: %.c  # Build executable from .c file
## Make knows how to do this without explicit rule

%.o: %.c
	$(COMPILE.c) $(OUTPUT_OPTION) $<
## $(COMPILE.c) is built-in variable for C compilation
```

---

## 🔄 Automatic Variables
*Special variables that reference targets and dependencies.*

```makefile
program: main.o utils.o lib.o
	gcc -o $@ $^  # $@ = program (target name)
## $@ is the target

main.o: main.c
	gcc -c $< -o $@  # $< = main.c (first dependency)
## $< is first prerequisite

program: main.o utils.o lib.o
	gcc -o $@ $^  # $^ = main.o utils.o lib.o (all dependencies)
## $^ is all prerequisites

program: main.o utils.o lib.o
	gcc -o $@ $+  # $+ = all dependencies with duplicates
## $+ includes duplicates if target listed multiple times

program: main.o utils.o lib.o
	gcc -o $@ $(filter %.o, $^)  # Filter dependencies
## $(filter pattern, list) filters dependencies

%.o: %.c
	gcc -c $<
	@echo "Compiled $(basename $@)"  # basename removes extension
## $@ is the specific target (.o file)

# Other automatic variables
$?  # Dependencies newer than target
$|  # Order-only dependencies
$*  # Stem (part matched by %)
```

---

## 🔁 Recursive Make
*Call make recursively in subdirectories.*

```makefile
all:  # Recursive make in subdirectories
	$(MAKE) -C src/  # $(MAKE) is recommended over 'make'
	$(MAKE) -C tests/

# Passing variables to submake
all:
	$(MAKE) -C src/ DEBUG=1 VERBOSE=1  # Pass variables

# Parallel recursive make
all:
	$(MAKE) -j4 -C src/  # -j4 parallel jobs

clean:  # Clean subdirectories
	$(MAKE) -C src/ clean
	$(MAKE) -C tests/ clean

# Typical structure
# Makefile (top-level)
# src/Makefile (compiles sources)
# tests/Makefile (runs tests)

# Top-level variables for subfiles
export CC = gcc  # export makes var available to submakes
export CFLAGS = -Wall -O2
```

---

## 📌 Common C Project Template
*Complete Makefile for C projects.*

```makefile
CC = gcc
CFLAGS = -Wall -Wextra -O2 -g
LDFLAGS = -lm
SRCDIR = src
OBJDIR = build
BINDIR = bin

SOURCES = $(wildcard $(SRCDIR)/*.c)  # wildcard finds all .c files
OBJECTS = $(SOURCES:$(SRCDIR)/%.c=$(OBJDIR)/%.o)  # Maps sources to objects
EXECUTABLE = $(BINDIR)/program

all: $(EXECUTABLE)  # Main target

$(EXECUTABLE): $(OBJECTS)
	mkdir -p $(BINDIR)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)
	@echo "Built $(EXECUTABLE)"

$(OBJDIR)/%.o: $(SRCDIR)/%.c
	mkdir -p $(OBJDIR)
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -rf $(OBJDIR) $(BINDIR)
	@echo "Cleaned build artifacts"

test: $(EXECUTABLE)
	./$(EXECUTABLE) --test
	@echo "Tests passed"

install: $(EXECUTABLE)
	install -m 755 $(EXECUTABLE) /usr/local/bin/

.PHONY: all clean test install

# Usage:
# make          - Build project
# make clean    - Remove build files
# make test     - Build and run tests
# make install  - Install executable
```

---

## ⚙️ Advanced Patterns
*Useful make patterns and idioms.*

```makefile
# Conditional execution
ifdef DEBUG  # If DEBUG variable is defined
  CFLAGS += -DDEBUG=1
endif

ifeq ($(OS),Windows_NT)  # Windows vs Unix
  RM = del /Q
else
  RM = rm -f
endif

# Include other makefiles
include config.mk  # Includes variables from config file
-include local.mk  # Include if exists; ignore if missing

# Function for repeated code
define compile_command  # Multi-line variable (function)
	$(CC) $(CFLAGS) -c $(1) -o $(2)
endef

%.o: %.c
	$(call compile_command, $<, $@)  # Call the function

# Silent output unless VERBOSE
ifndef VERBOSE
  QUIET = @
else
  QUIET =
endif

program: main.o
	$(QUIET)$(CC) -o $@ $^
	$(QUIET)@echo "Compilation silent unless VERBOSE=1"

# Build all targets
%: %.o
	$(CC) -o $@ $^  # Generic rule to build any executable

# PHONY tricks
.PHONY: targets  # List available targets
targets:
	@grep -E '^\w.*:' Makefile | sed 's/:.*//g'
## Lists all non-phony targets
```

---

## 🚀 Running Make
*Execute make commands.*

```bash
make  # Build default target (usually 'all')
## Builds only targets with changed dependencies

make clean  # Run specific target
## Executes the clean target

make -j4  # Parallel build with 4 jobs
## Speeds up compilation on multi-core

make DEBUG=1  # Pass variable on command line
## Override Makefile variable

make -n  # Dry run; shows commands without executing
## Useful for testing before running

make -d  # Debug output; shows make decisions
## Verbose output of target evaluation

make -f custom.mk  # Use different makefile
## Default is 'Makefile' or 'makefile'

make --always-make  # Rebuild everything
## Ignores timestamps; forces all targets
```
