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
	cd terraform && terraform apply      # ✅ Same line
	cd terraform
	terraform apply                      # ❌ Runs in the original folder
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

### Required variable

```makefile
deploy:
	@test -n "$(ENV)" || (echo "ENV is required: make deploy ENV=prod" && exit 1)
```

---

## Self-documenting help

Write `## description` after each target: `make` (or `make help`) lists them.

```makefile
.DEFAULT_GOAL := help

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | \
	  awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'
```

---

## DevOps template

```makefile
SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c        # Stop on errors, unset vars, failed pipes
.DEFAULT_GOAL := help

ENV   ?= dev
TAG   ?= $(shell git rev-parse --short HEAD)
IMAGE := ghcr.io/poissonchevre/web
TF    := terraform -chdir=terraform/$(ENV)

.PHONY: help init plan apply destroy fmt lint build push deploy logs clean

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | \
	  awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'

# --- Terraform ---
init: ## terraform init
	$(TF) init

plan: ## terraform plan (ENV=dev|prod)
	$(TF) plan -out=tfplan

apply: plan ## terraform apply (runs plan first)
	$(TF) apply tfplan

destroy: ## terraform destroy (asks for confirmation)
	$(TF) destroy

# --- Quality ---
fmt: ## Format Terraform files
	terraform fmt -recursive

lint: ## Check formatting and YAML
	terraform fmt -check -recursive
	yamllint .

# --- Container ---
build: ## Build the image
	docker build -t $(IMAGE):$(TAG) .

push: build ## Push the image to GHCR
	docker push $(IMAGE):$(TAG)

# --- Kubernetes ---
deploy: ## Deploy to the cluster (ENV=dev|prod)
	kubectl apply -k k8s/overlays/$(ENV)
	kubectl rollout status deploy/web -n $(ENV)

logs: ## Follow the app logs
	kubectl logs -f deploy/web -n $(ENV)

clean: ## Remove local build files
	rm -rf terraform/*/.terraform terraform/*/tfplan
```

```bash
make              # List the tasks
make plan ENV=prod
make push TAG=1.2.0
make -n deploy    # Show the commands without running them
```

`apply: plan` = `plan` runs first. Dependencies are the way to chain tasks.

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
