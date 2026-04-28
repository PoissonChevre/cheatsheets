# 🔍 Regex — Cheat Sheet
*Pattern matching language for finding, extracting, and manipulating text in strings.*

---

## 🎯 Anchors & Quantifiers
*Match positions and repetitions.*

```regex
^hello  # Start of line anchor; matches "hello" at beginning
## ^ inside character class [^a-z] means negation instead

hello$  # End of line anchor; matches "hello" at end
## $ matches before final newline in multiline mode

^hello$  # Match entire line with exactly "hello"
## Combines start and end anchors

\bhello\b  # Word boundaries; matches "hello" as complete word
## \b matches between \w and \W characters

hello?  # ? means 0 or 1 occurrence of "o"
## Makes preceding element optional

hello*  # * means 0 or more occurrences of "o"
## Greedy; matches as many as possible

hello+  # + means 1 or more occurrences of "o"
## Must have at least one

hello{3}  # {3} means exactly 3 occurrences of "o"
## Precise repetition count

hello{2,4}  # {2,4} means 2 to 4 occurrences of "o"
## Range of repetitions

hello{2,}  # {2,} means 2 or more occurrences of "o"
## Open-ended repetition

hello??  # Non-greedy version of ?
## Matches as few as possible (usually with ?, *, +, {})
```

---

## 📦 Character Classes
*Match characters from sets.*

```regex
[abc]  # Match a, b, or c
## Character class; any single character listed

[a-z]  # Match any lowercase letter
## Range notation; a through z

[A-Z]  # Match any uppercase letter
## Capital A through Z

[0-9]  # Match any digit
## Numbers 0 through 9

[a-zA-Z0-9]  # Match letters and digits
## Combine ranges

[^abc]  # Match anything except a, b, c
## ^ at start means negation

[a-z^]  # Match letters or literal ^ character
## ^ at end or middle is literal

\d  # Match any digit (0-9)
## Shorthand for [0-9]

\D  # Match non-digit
## Opposite of \d

\w  # Match word character (a-z, A-Z, 0-9, _)
## Shorthand for [a-zA-Z0-9_]

\W  # Match non-word character
## Opposite of \w

\s  # Match whitespace (space, tab, newline)
## Any whitespace character

\S  # Match non-whitespace
## Opposite of \s

.  # Match any character except newline
## Wildcard; matches almost anything

[.]  # Match literal dot
## Escape special chars inside character class with literal
```

---

## 👥 Groups & Alternation
*Group patterns and match alternatives.*

```regex
(hello|goodbye)  # Match "hello" or "goodbye"
## | is alternation; matches one or the other

(foo)bar  # Group "foo"; captures as group 1
## Parentheses create groups for references

(?:foo)bar  # Non-capturing group
## (?:...) groups without capturing

(foo)(bar)  # Two groups; group 1="foo", group 2="bar"
## Used in replacement to reference captured text

\1  # Reference group 1 in same pattern
## Backreference; matches same text as group 1

(foo)\1  # Match "foofoo"
## Repeats group 1

([a-z])\1  # Match doubled letter like "aa", "bb", "cc"
## Backreference with character class

(.+)@(.+)\.com  # Email-like pattern
## Groups 1=username, 2=domain

(?P<name>pattern)  # Named group (Python)
## Named groups improve readability

(?P=name)  # Reference named group (Python)
## Backreference using group name
```

---

## 🔮 Lookahead & Lookbehind
*Match based on surrounding text without including it.*

```regex
foo(?=bar)  # Positive lookahead; "foo" only if followed by "bar"
## (?=...) matches without consuming

foo(?!bar)  # Negative lookahead; "foo" NOT followed by "bar"
## (?!...) negative lookahead

(?<=foo)bar  # Positive lookbehind; "bar" only if preceded by "foo"
## (?<=...) matches without consuming

(?<!foo)bar  # Negative lookbehind; "bar" NOT preceded by "foo"
## (?<!...) negative lookbehind

\d+(?=px)  # Digits followed by "px" (matches digits only)
## Lookahead doesn't include "px"

(?<=$)\d+  # Digits preceded by "$" (matches digits only)
## Lookbehind doesn't include "$"

\b\w+(?=s\b)  # Words ending with "s" (plural nouns)
## Lookahead without consuming "s"
```

---

## 📝 Common Patterns
*Ready-to-use regex for common tasks.*

### Email
```regex
^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$
## Basic email validation; not RFC 5322 compliant
```

### IP Address (IPv4)
```regex
^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$
## Validates 0-255 for each octet
```

### URL
```regex
^https?://[^\s/$.?#].[^\s]*$
## Simple URL validation

^(https?|ftp)://[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(/.*)?$
## More thorough URL pattern
```

### Phone Number (US)
```regex
^(\d{3}[-.]?)?\d{3}[-.]?\d{4}$
## Matches 1234567890, 123-456-7890, (123) 456-7890
```

### Date (YYYY-MM-DD)
```regex
^\d{4}-(?:0[1-9]|1[0-2])-(?:0[1-9]|[12]\d|3[01])$
## Validates valid months and days
```

### Hex Color
```regex
^#(?:[0-9a-fA-F]{3}){1,2}$
## Matches #FFF or #FFFFFF
```

### Username (alphanumeric, underscore, 3-16 chars)
```regex
^[a-zA-Z0-9_]{3,16}$
## Restricts to safe characters
```

### Password (8+ chars, uppercase, lowercase, digit)
```regex
^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$
## Lookaheads enforce requirements
```

---

## 🔧 Usage in Grep
*Apply regex with grep command.*

```bash
grep 'pattern' file.txt  # Search for pattern in file
## Matches lines containing pattern

grep -E 'pattern1|pattern2' file.txt  # Use extended regex (ERE)
## -E enables |, +, {}, () without escaping

grep -P 'pattern' file.txt  # Use Perl regex (PCRE)
## -P enables advanced features like lookahead

grep '^ERROR' file.txt  # Match lines starting with ERROR
## ^ anchor for start of line

grep -i 'pattern' file.txt  # Case-insensitive search
## -i ignores case

grep -c 'pattern' file.txt  # Count matching lines
## -c outputs only count

grep -n 'pattern' file.txt  # Show line numbers
## -n prefixes matches with line number

grep 'pattern' file1.txt file2.txt  # Search multiple files
## Shows filename:line when multiple files
```

---

## ✂️ Usage in Sed
*Apply regex with sed for text substitution.*

```bash
sed 's/old/new/' file.txt  # Replace first occurrence on each line
## s is substitute command

sed 's/old/new/g' file.txt  # Replace all occurrences on each line
## g flag means global

sed 's/^[[:space:]]*//g' file.txt  # Remove leading whitespace
## ^[[:space:]]* matches start-of-line whitespace

sed -E 's/(foo)(bar)/\2\1/' file.txt  # Swap captured groups
## -E enables extended regex; \1, \2 reference groups

sed -n 's/pattern/replacement/gp' file.txt  # Print only changed lines
## -n suppresses default output; p prints matches

sed -i 's/old/new/g' file.txt  # Edit file in-place
## -i modifies file directly

sed '5,10s/old/new/g' file.txt  # Replace in line range 5-10
## Range notation for subset of lines
```

---

## 🐍 Usage in Python
*Apply regex with Python's re module.*

```python
import re

re.search('pattern', text)  # Find first match
## Returns match object or None

re.findall('pattern', text)  # Find all matches
## Returns list of all matching strings

re.sub('pattern', 'replacement', text)  # Replace all matches
## Returns new string with replacements

match = re.match('^[0-9]+', '123abc')  # Match at string start
## match.group() returns matched text

re.compile('pattern').finditer(text)  # Find all with positions
## Iterator over match objects

re.split('[,;]', text)  # Split by regex pattern
## Splits on comma or semicolon

re.search(r'(\w+)@(\w+)', email).groups()  # Get captured groups
## .groups() returns tuple of all captures

re.IGNORECASE  # Case-insensitive flag
## Used as flag argument in re functions

re.MULTILINE  # ^ and $ match line boundaries
## Default: match string start/end only

re.DOTALL  # . matches newlines too
## Default: . doesn't match newline
```

---

## 📝 Usage in Vim
*Apply regex in Vim text editor.*

```vim
/pattern  # Search for pattern
## Highlights all matches; press n for next

:%s/old/new/g  # Replace all in file
## % means entire file

:5,10s/old/new/g  # Replace in lines 5-10
## Range notation

:%s/\<old\>/new/g  # Replace whole words only
## \< and \> are word boundaries

:%s/^/prefix/  # Add prefix to every line
## ^ with empty match at line start

:%s/$/suffix/  # Add suffix to every line
## $ with empty match at line end

:%s/\(.*\) \(.*\)/\2 \1/g  # Vim uses \( \) for groups
## Vim regex needs escaping for groups and {, }

:set hlsearch incsearch  # Highlight and incremental search
## Makes regex feedback immediate

?pattern  # Search backward
## Opposite direction from /
```
