# Regex

Patterns for grep, sed and awk, the three flavors, and ready-to-use sysadmin examples.

[← Back to index](./README.md) · grep, sed, awk basics: [essentials.md](./essentials.md#search)

---

## Basics

| Pattern | Matches |
|---|---|
| `.` | Any character |
| `^` / `$` | Start / end of line |
| `*` | 0 or more of the previous item |
| `+` | 1 or more |
| `?` | 0 or 1 (optional) |
| `{3}` / `{2,4}` / `{2,}` | Exactly 3 / 2 to 4 / 2 or more |
| `[abc]` / `[a-z]` / `[^abc]` | One of / a range / NOT one of |
| `a\|b` | a or b |
| `( )` | Group (and capture for `\1`) |
| `\.` | A real dot (escape special characters) |
| `\b` | Word boundary: `\bcat\b` matches "cat", not "category" |

---

## Three flavors

The same idea, different escaping depending on the tool.

| Flavor | Tools | `+ ? \| ( ) { }` | Extras |
|---|---|---|---|
| **Basic (BRE)** | `grep`, `sed`, `vim` | Need a `\`: `\+ \? \| \( \) \{ \}` | — |
| **Extended (ERE)** | `grep -E`, `sed -E`, `awk` | Work as is | — |
| **Perl (PCRE)** | `grep -P`, Python, most languages | Work as is | `\d`, lazy `*?`, lookarounds, `\K` |

Use `grep -E` and `sed -E` by default: no backslash soup.

### Character classes

| POSIX (everywhere) | PCRE | Meaning |
|---|---|---|
| `[[:digit:]]` | `\d` | Digit |
| `[[:alpha:]]` | — | Letter |
| `[[:alnum:]]` | `\w` (+ `_`) | Letter or digit |
| `[[:space:]]` | `\s` | Space, tab, new line |
| `[[:upper:]]` / `[[:lower:]]` | — | Upper / lower case |

`\d` does **not** work in `grep -E` or `sed`: use `[0-9]`. GNU grep and sed accept `\w` and `\s`.

---

## Groups and back-references

```bash
sed -E 's/^(\w+)=(.*)$/\2=\1/' file          # Swap key and value
sed -E 's/([0-9]{4})-([0-9]{2})-([0-9]{2})/\3\/\2\/\1/' dates.txt   # 2026-10-24 → 24/10/2026
grep -E '(ab)\1' file                         # "abab"
```

## Greedy and lazy

```bash
echo '<a><b>' | grep -oE '<.*>'      # <a><b>   — .* takes as much as possible
echo '<a><b>' | grep -oP '<.*?>'     # <a> <b>  — .*? as little as possible (PCRE only)
echo '<a><b>' | grep -oE '<[^>]*>'   # <a> <b>  — same result without PCRE
```

## Lookarounds and \K (PCRE)

Match something **next to** a text, without including that text.

```bash
grep -oP 'version=\K[0-9.]+' app.conf        # Only the number after "version="
grep -oP '(?<=port: )\d+' config.yaml        # Number preceded by "port: "
grep -oP '\d+(?=ms)' latency.log             # Number followed by "ms"
grep -P 'error(?!.*retry)' app.log           # "error" not followed by "retry" on the line
```

---

## Sysadmin examples

```bash
# Active config only (no comments, no empty lines)
grep -Ev '^\s*(#|$)' /etc/ssh/sshd_config

# Set a config value, commented or not
sed -i -E 's/^#?PermitRootLogin .*/PermitRootLogin no/' /etc/ssh/sshd_config

# Comment / uncomment a line
sed -i 's/^Listen 80/#&/' httpd.conf          # & = the whole match
sed -i 's/^#\(Listen 80\)/\1/' httpd.conf

# Delete empty lines / trailing spaces
sed -i '/^\s*$/d' file
sed -i -E 's/\s+$//' file

# Paths in a pattern: change the delimiter
sed -i 's|/var/www/old|/srv/www/new|g' site.conf

# Top 10 client IPs in a web log
grep -oE '^([0-9]{1,3}\.){3}[0-9]{1,3}' access.log | sort | uniq -c | sort -rn | head

# HTTP 5xx errors
grep -E '" 5[0-9]{2} ' access.log

# Errors and warnings, case-insensitive
grep -Ei 'error|warn|fail' /var/log/syslog
journalctl -u nginx --grep 'error|timeout' --case-sensitive=false

# Failed SSH logins with the source IP
grep -oP 'Failed password for .* from \K[0-9.]+' /var/log/auth.log | sort | uniq -c

# Users with UID >= 1000
awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd

# Lines between two markers
sed -n '/BEGIN CERTIFICATE/,/END CERTIFICATE/p' bundle.pem
```

### Patterns

| What | Pattern (ERE) |
|---|---|
| IPv4 (simple) | `([0-9]{1,3}\.){3}[0-9]{1,3}` |
| IPv4 + CIDR | `([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]{1,2}` |
| MAC address | `([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}` |
| Date YYYY-MM-DD | `[0-9]{4}-[0-9]{2}-[0-9]{2}` |
| Time HH:MM:SS | `[0-9]{2}:[0-9]{2}:[0-9]{2}` |
| Email (rough) | `[[:alnum:]._%+-]+@[[:alnum:].-]+\.[[:alpha:]]{2,}` |
| Empty or comment line | `^\s*(#\|$)` |
| Version number | `[0-9]+\.[0-9]+(\.[0-9]+)?` |

These patterns **find** values. They don't fully **validate** them (`999.1.1.1` matches the simple IPv4 pattern).

---

## In other tools

```python
import re
re.search(r'(\d+)ms', line).group(1)       # First match, group 1
re.findall(r'\d+\.\d+\.\d+\.\d+', text)    # All matches
re.sub(r'\s+', ' ', text)                  # Replace
# r'...' = raw string: no double backslashes
```

```vim
:%s/\v(\w+) (\w+)/\2 \1/g     " \v = very magic: ERE-like syntax in Vim
/\<word\>                     " Whole word in Vim
```

Test patterns on [regex101.com](https://regex101.com) (choose the flavor: PCRE, Python...).

---

## Pitfalls

- Put patterns in **single quotes**: the shell must not touch `$`, `*`, `\`.
- `.` matches any character: escape it for a real dot (`\.`).
- `grep 'a+'` (basic) looks for "a+" literally: use `grep -E`.
- `\d` doesn't work in `grep -E` or `sed`: use `[0-9]`.
- `.*` is greedy: use `[^x]*` or PCRE `.*?`.
- `sed -i` has no undo: test without `-i` first, or use `-i.bak`.
- With `/` in the pattern (paths), use another sed delimiter: `s|a|b|`.
