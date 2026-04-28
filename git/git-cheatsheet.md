# Git Cheat Sheet
*Distributed version control system for tracking code changes*

## Setup & Config
*Configure git identity and defaults*

```bash
git config --global user.name "Your Name"  # Set global username
git config --global user.email "you@example.com"  # Set global email
git config --list  # Show all configuration settings
git config --global core.editor "vim"  # Set default editor
git config --global alias.st status  # Create command alias
```

## Init & Clone
*Initialize or copy repositories*

```bash
git init  # Create new local repository
git clone <url>  # Clone remote repository
git clone <url> <directory>  # Clone into specific directory
git clone --depth 1 <url>  # Shallow clone (faster for large repos)
git clone --branch <branch> <url>  # Clone specific branch
```

## Staging & Commits
*Stage changes and record snapshots*

```bash
git add <file>  # Stage specific file
git add .  # Stage all changes
git add -p  # Interactive staging (review changes)
git status  # Show staged and unstaged changes
git diff  # Show unstaged changes
git diff --staged  # Show staged changes
git commit -m "message"  # Create commit with message
git commit -am "message"  # Stage and commit tracked files
git commit --amend  # Modify last commit (don't push after!)
```

## Branching
*Create and manage branches*

```bash
git branch  # List local branches
git branch -a  # List all branches (local + remote)
git branch <name>  # Create new branch
git checkout <branch>  # Switch to branch
git checkout -b <branch>  # Create and switch to branch
git branch -d <branch>  # Delete merged branch
git branch -D <branch>  # Force delete branch
git branch -m <old> <new>  # Rename branch
git branch -v  # Show last commit per branch
```

## Merging & Rebase
*Integrate changes from different branches*

```bash
git merge <branch>  # Merge branch into current branch
git merge --no-ff <branch>  # Merge with merge commit (preserves history)
git merge --squash <branch>  # Combine commits before merging
git rebase <branch>  # Reapply commits on top of branch
git rebase -i HEAD~3  # Interactive rebase last 3 commits
git rebase --abort  # Cancel rebase in progress
git rebase --continue  # Continue after resolving conflicts
```

## Remotes
*Manage remote repository connections*

```bash
git remote  # List remote names
git remote -v  # Show remote URLs
git remote add <name> <url>  # Add new remote
git remote remove <name>  # Remove remote
git remote rename <old> <new>  # Rename remote
git push <remote> <branch>  # Push branch to remote
git push <remote> --all  # Push all branches
git pull <remote> <branch>  # Fetch and merge from remote
git fetch <remote>  # Download updates without merging
git fetch --all  # Fetch from all remotes
```

## Undoing
*Undo changes at various stages*

```bash
git restore <file>  # Discard changes in working directory
git restore --staged <file>  # Unstage file
git reset HEAD~1  # Undo last commit (keep changes staged)
git reset --soft HEAD~1  # Undo commit, keep changes staged
git reset --hard HEAD~1  # Undo commit, discard changes
git revert <commit>  # Create new commit that undoes changes
git clean -fd  # Remove untracked files and directories
```

## Stash
*Temporarily save work in progress*

```bash
git stash  # Save uncommitted changes
git stash list  # Show all stashes
git stash pop  # Apply and remove latest stash
git stash apply  # Apply latest stash (keep it)
git stash apply stash@{0}  # Apply specific stash
git stash drop  # Delete latest stash
git stash drop stash@{0}  # Delete specific stash
```

## Log & Diff
*View history and changes*

```bash
git log  # Show commit history
git log --oneline  # Condensed log format
git log --graph --all --oneline --decorate  # Visual branch graph
git log -p  # Show changes per commit
git log <file>  # Show commits for specific file
git log --author="name"  # Filter by author
git log --grep="pattern"  # Search commit messages
git diff <commit1> <commit2>  # Show differences between commits
git diff <branch1> <branch2>  # Compare branches
git show <commit>  # Show specific commit details
```

## Tags
*Mark important points in history*

```bash
git tag  # List tags
git tag <name>  # Create lightweight tag
git tag -a <name> -m "message"  # Create annotated tag
git push origin <tag>  # Push specific tag
git push origin --tags  # Push all tags
git tag -d <name>  # Delete local tag
git push origin --delete <tag>  # Delete remote tag
```

## Advanced
*Complex operations for experienced users*

```bash
git cherry-pick <commit>  # Apply specific commit to current branch
git bisect start  # Begin binary search for problematic commit
git bisect bad  # Mark current commit as bad
git bisect good <commit>  # Mark commit as good reference point
git submodule add <url> <path>  # Add submodule
git submodule update --init --recursive  # Initialize submodules
git reflog  # Show reference changes (useful for recovery)
git fsck --lost-found  # Find lost commits
```
