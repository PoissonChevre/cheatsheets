# Make — Cheat Sheet

In DevOps, a `Makefile` is mostly a **task runner**: short names for long commands (`make plan`, `make deploy`), the same for everyone in the project and in CI.

---

## Rule syntax

```makefile
target: dependencies
	command          # MUST start with a TAB, not spaces
	command
```

```bash
make             # Run the first target (or .DEFAULT_GOAL)
make plan        # Run one target
make build push  # Several targets, in order
```

- `make` prints each command before running it. `@command` hides it.
- If a command fails, make stops.
- Each line runs in a **new shell**: `cd dir` on one line is forgotten on the next.

```makefile
deploy:
	cd terraform && terraform apply      # OK: same line
	cd terraform
	terraform apply                      # Wrong: runs in the original folder
```

---

## .PHONY

Make thinks a target is a **file**. If a file or folder named `test` exists, `make test` says "up to date" and does nothing. `.PHONY` says "this is a task, not a file".

```makefile
.PHONY: help build test deploy clean
```

Declare every task target as `.PHONY`.

---

## Variables

```makefile
ENV  ?= dev                                  # Default, can be overridden
TAG  ?= $(shell git rev-parse --short HEAD)  # Output of a command
IMAGE := ghcr.io/poissonchevre/web           # Set once (:= evaluated now)
ARGS  += --verbose                           # Append

deploy:
	kubectl apply -k overlays/$(ENV)         # Use with $(VAR)
	echo "Home is $$HOME"                    # $$ = shell variable
```

```bash
make deploy ENV=prod          # Override on the command line
ENV=prod make deploy          # Environment variable (works with ?=)
```

| Operator | Meaning |
|---|---|
| `=` | Evaluated each time it is used |
| `:=` | Evaluated once, now |
| `?=` | Only if not already set (env or command line) |
| `+=` | Append |

---

## Help target

Put `help` first: `make` alone then shows the list of tasks.

```makefile
help:
	@echo "make plan     Show Terraform changes"
	@echo "make apply    Apply Terraform changes"
	@echo "make deploy   Deploy the app to Kubernetes"
```

---

## DevOps template

```makefile
ENV ?= dev
TAG ?= latest
IMAGE = ghcr.io/poissonchevre/web

.PHONY: help plan apply build push deploy

help:
	@echo "make plan     terraform plan   (ENV=dev or prod)"
	@echo "make apply    terraform apply"
	@echo "make build    build the Docker image"
	@echo "make push     push the image to GHCR"
	@echo "make deploy   deploy to Kubernetes"

plan:
	cd terraform/$(ENV) && terraform plan

apply:
	cd terraform/$(ENV) && terraform apply

build:
	docker build -t $(IMAGE):$(TAG) .

push: build
	docker push $(IMAGE):$(TAG)

deploy:
	kubectl apply -k k8s/overlays/$(ENV)
```

```bash
make                     # Shows the help
make plan ENV=prod
make push TAG=1.2.0
make -n deploy           # Show the commands without running them
```

`push: build` = `build` runs first. Dependencies are the way to chain tasks.

---

## Build files (the original use)

Make runs a rule only if the target file is **missing or older** than its dependencies.

```makefile
site.html: site.md style.css
	pandoc site.md -c style.css -o $@

%.pdf: %.md                   # Pattern: any .pdf from the .md with the same name
	pandoc $< -o $@
```

| Variable | Value |
|---|---|
| `$@` | The target |
| `$<` | The first dependency |
| `$^` | All dependencies |

---

## Useful options

```bash
make -n TARGET        # Dry run: print commands only
make -C dir TARGET    # Run the Makefile of another folder
make -f other.mk      # Use another file
make -j4              # 4 jobs in parallel
make -B TARGET        # Force (ignore file dates)
make -k               # Keep going after errors
```

Other tricks:

```makefile
-rm -f out.txt                # "-" = ignore an error on this line
include .env                  # Load KEY=value variables (-include = OK if missing)
export                        # Pass all variables to commands as env variables
$(MAKE) -C sub/ build         # Call make inside make (use $(MAKE), not make)
```

---

## Pitfalls

- Commands start with a **TAB**: "missing separator" = spaces instead of a TAB.
- Each line is a new shell: join with `&&` or `\`.
- Shell variables need `$$` (`$$HOME`), make variables `$(VAR)`.
- Forget `.PHONY` and a file with the same name blocks the target.
- `make` alone runs the **first** target: put `help` first or set `.DEFAULT_GOAL`.
- `include .env`: values keep their quotes, and `export` makes them visible to every command.
