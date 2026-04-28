# 🤝 Contributing Guidelines

Thank you for your interest in contributing to DevOps Cheat Sheets! This project welcomes contributions from everyone.

---

## 📝 How to Contribute

### Adding a New Cheat Sheet

1. **Fork the repository** and create a feature branch
   ```bash
   git checkout -b feature/add-<tool>-cheatsheet
   ```

2. **Create a new directory** for your tool (if not already existing)
   ```bash
   mkdir <tool-name>
   ```

3. **Create the cheat sheet** as a Markdown file
   ```bash
   touch <tool-name>/<tool-name>-cheatsheet.md
   ```

### Format & Style Standards

#### File Naming
- Use lowercase with hyphens: `tool-name-cheatsheet.md`
- PDFs should follow the same naming: `tool-name-cheatsheet.pdf`

#### Markdown Structure

```markdown
# 📚 Tool Name Cheatsheet

[Brief description of the tool]

---

## 🚀 Quick Start

[Basic installation or setup]

---

## 📋 Commands / Section

### Subsection

\`\`\`bash
command --option argument  # What this command does
\`\`\`

### Important Notes

Use `##` comments for important alternatives or gotchas:
\`\`\`bash
command option1  # Default behavior
## command option2  # Alternative approach
\`\`\`

---

## 🔗 References

- [Official documentation](https://example.com)
- [Useful guide](https://example.com)
```

#### Key Points

✅ Use **emoji titles** for sections (🚀, 📋, 🔧, 💡, etc.)
✅ Keep **inline comments** short and descriptive
✅ Use `##` comment prefix for **alternatives or gotchas**
✅ Include **practical examples** with real-world usage
✅ Organize by **logical subsections** for quick reference
✅ Keep **markdown formatting consistent** throughout
✅ Link to **official documentation** in references section
✅ Use **English language** (French comments acceptable for French-specific resources)

### Updating an Existing Cheat Sheet

1. Edit the relevant file
2. Ensure changes are accurate and tested
3. Keep the formatting consistent with the rest of the file
4. Submit a pull request with a clear description of changes

---

## 📋 Pull Request Process

1. **Update the README.md** if adding a new tool
   - Add entry to appropriate category table
   - Update the stats count if needed
   - Add directory reference if creating new folder

2. **Commit your changes** with clear messages
   ```bash
   git add <file>
   git commit -m "feat: add <tool> cheatsheet with <sections>"
   # or
   git commit -m "docs: update <tool> cheatsheet with <improvements>"
   ```

3. **Push to your fork** and **create a pull request**
   - Describe what was added/changed
   - Link any related issues
   - Include before/after examples if applicable

4. **Address feedback** from maintainers promptly

---

## 🎯 Contribution Ideas

### Content Improvements
- [ ] Expand existing cheat sheets with additional commands
- [ ] Add practical examples and use cases
- [ ] Fix typos, improve clarity, or enhance formatting
- [ ] Add French translations for French-specific sections
- [ ] Create PDF versions of existing Markdown files

### New Tools to Add
- [ ] CI/CD tools (Jenkins, GitLab CI, GitHub Actions)
- [ ] Container registries (Harbor, ECR)
- [ ] Monitoring tools (Prometheus, Grafana)
- [ ] Logging solutions (ELK, Splunk)
- [ ] Configuration management (Puppet, Chef)
- [ ] Cloud platforms (AWS, GCP, Azure)

### Project Improvements
- [ ] Add search functionality
- [ ] Create interactive web version
- [ ] Add diagrams and visual references
- [ ] Build command index/glossary
- [ ] Create quick reference cards

---

## ⚠️ Guidelines to Follow

- ❌ **Don't** submit PDFs for review (they're harder to diff) - use Markdown first
- ❌ **Don't** break existing links or move files without updating README
- ❌ **Don't** include external logos or large images
- ✅ **Do** test commands before including them
- ✅ **Do** provide working, verified examples
- ✅ **Do** follow the existing format and style
- ✅ **Do** be respectful and constructive in discussions

---

## 📞 Questions or Issues?

- **Found an error?** Open an [issue](https://github.com/PoissonChevre/devops_cheat_sheets/issues)
- **Have an idea?** Open a [discussion](https://github.com/PoissonChevre/devops_cheat_sheets/discussions) first
- **Need help?** Comment on an issue or PR

---

## 📜 Code of Conduct

Be respectful, inclusive, and constructive. Treat all contributors with courtesy and professionalism.

---

Thank you for making this project better! 🙌
