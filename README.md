# ADR AI Skills

**AI-Enhanced Architecture Decision Records** - Detect, generate, and enforce ADRs with AI.

Compatible with existing ADR tools (adr-tools, MADR, log4brains) while providing AI-powered automatic detection, generation, and enforcement of design decisions.

[日本語ドキュメント](./README.ja.md)

## What Makes This Different?

| Traditional ADR Tools | ADR AI Skills |
|----------------------|---------------|
| Manual ADR creation | AI **auto-detects** decisions and drafts ADRs |
| Fixed format | **Multi-format** support (Nygard, MADR) |
| No enforcement | **CI integration** for constraint checking |
| Separate workflow | **Integrated** with JJ/Git/PR/Release |

## Compatibility

### Supported Formats

| Format | Compatible Tools | Import | Export |
|--------|-----------------|:------:|:------:|
| Extended | ADR AI Skills | ✓ | ✓ |
| Nygard (Classic) | [adr-tools](https://github.com/npryce/adr-tools) | ✓ | ✓ |
| MADR | [MADR](https://github.com/adr/madr), [log4brains](https://github.com/thomvaill/log4brains) | ✓ | ✓ |

### Migration from Existing ADRs

```bash
# Import from adr-tools
/adr import docs/adr/*.md --format nygard

# Import from MADR
/adr import docs/decisions/*.md --format madr

# Export back to adr-tools format
/adr export --all --format nygard --output docs/adr/
```

---

## Overview

```
JJ History (ephemeral) → ADR (persistent) → constraints.json (enforced)
```

| Layer | Purpose | Storage |
|-------|---------|---------|
| Experimentation | Trials, failures, retries | JJ (.jj) |
| Design Decisions | Why this design? | ADR (docs/adr/) |
| Artifacts | Buildable code | Git/GitHub |

---

## Installation

### Prerequisites

```bash
# JJ (Jujutsu) - recommended
brew install jj   # macOS
# or: cargo install jujutsu

# Claude Code
npm install -g @anthropic-ai/claude-code
```

### Method 1: Plugin Installation (Recommended)

Install into existing projects **without breaking** your configuration.

```bash
# 1. Get the plugin
git clone https://github.com/GodsGolemInc/adr-ai-skills /tmp/adr-ai-skills

# 2. Install into your project
cd /path/to/your/project
/tmp/adr-ai-skills/plugin/adr-ai-skills/install.sh .

# 3. Verify
claude
> /adr list
```

#### Installer Behavior

| Action | If file exists |
|--------|---------------|
| Create `.adr-ai-skills/` | Backup and recreate |
| Create `docs/adr/` | Preserve as-is |
| `docs/constraints.json` | Preserve (no overwrite) |
| `.claude/settings.json` | **Merge** (preserve existing) |
| `CLAUDE.md` | **Append** (preserve existing) |
| **Initialize VCS** | JJ (colocated) if available, else Git |

#### Uninstall

```bash
/tmp/adr-ai-skills/plugin/adr-ai-skills/uninstall.sh .
```

ADRs and constraints are preserved; only plugin files are removed.

### Method 2: Manual Installation

For fine-grained customization:

```bash
# Create only necessary directories
mkdir -p docs/adr docs/design-notes .adr-ai-skills

# Copy required files
cp -r plugin/adr-ai-skills/skills .adr-ai-skills/
cp -r plugin/adr-ai-skills/prompts .adr-ai-skills/
cp -r plugin/adr-ai-skills/templates .adr-ai-skills/

# Manually add to CLAUDE.md
# Manually add skills to .claude/settings.json
```

### Method 3: Clone as Template (New Projects)

```bash
git clone https://github.com/GodsGolemInc/adr-ai-skills my-new-project
cd my-new-project
rm -rf .git .jj
jj git init --colocate  # Recommended: JJ with Git
# or: git init           # Git only
```

---

## Directory Structure

### After Plugin Installation

```
your-project/
├── .adr-ai-skills/             # Plugin
│   ├── plugin.json             # Plugin configuration
│   ├── skills/                 # Claude Code Skills
│   ├── prompts/                # AI prompts
│   ├── templates/              # ADR templates
│   └── jj-workflow.sh          # CLI helper
├── .claude/
│   └── settings.json           # Skills registered (merged)
├── CLAUDE.md                   # Project config (appended)
├── .jj/                        # JJ repository (if initialized)
├── .git/                       # Git repository (colocated with JJ)
├── docs/
│   ├── adr/                    # ADR documents
│   ├── design-notes/           # Lightweight design notes
│   └── constraints.json        # Machine-readable constraints
└── (your existing files...)
```

---

## Usage

### Claude Code Skills (7 Skills)

```bash
claude  # Start Claude Code
```

#### Phase 1: Development & ADR Creation

| Skill | Description |
|-------|-------------|
| `/adr` | ADR management (list, create, import/export) |
| `/jj-analyze` | AI detection of design decisions from JJ changes |
| `/design-review` | AI architectural compliance review |
| `/constraints-check` | Constraint checking for CI |

#### Phase 2: Release & Publishing

| Skill | Description |
|-------|-------------|
| `/sync` | JJ → Git sync (with pre-checks) |
| `/pr` | Create PR (auto-links ADRs) |
| `/release` | Release tagging & notes generation |

### ADR Management (`/adr`)

```bash
# Basic operations
/adr list              # List all ADRs
/adr new "Title"       # Create new
/adr extract abc123    # Extract from JJ change
/adr validate          # Validate format
/adr sync              # Sync constraints.json

# Format conversion
/adr new "Title" --format nygard    # Create in Nygard format
/adr new "Title" --format madr      # Create in MADR format
/adr export ADR-0001 --format nygard  # Export
/adr import docs/adr/*.md --format nygard  # Import
```

### JJ Change Analysis (`/jj-analyze`)

```bash
/jj-analyze abc123     # Analyze specific change
/jj-analyze recent     # Analyze last 5 changes
/jj-analyze recent 10  # Analyze last 10 changes
```

### Design Review (`/design-review`)

```bash
/design-review abc123  # Review a change
/design-review staged  # Review staged changes
/design-review --strict  # CI mode (strict)
```

### Constraint Check (`/constraints-check`)

```bash
/constraints-check           # Full check
/constraints-check src/      # Check specific path
/constraints-check --ci      # CI output format
```

### Git Sync (`/sync`)

```bash
/sync                  # JJ → Git sync
/sync --dry-run        # Preview
/sync --skip-review    # Skip review
```

### PR Creation (`/pr`)

```bash
/pr                    # Create PR (auto-detect ADRs)
/pr "Title"            # With title
/pr --draft            # Draft PR
```

### Release (`/release`)

```bash
/release major         # v1.0.0 → v2.0.0
/release minor         # v1.0.0 → v1.1.0
/release patch         # v1.0.0 → v1.0.1
/release v2.1.0        # Direct version
```

---

## Workflow

### Complete Development Flow

```
┌─────────────────────────────────────────────────────────────┐
│  Phase 1: Development                                        │
├─────────────────────────────────────────────────────────────┤
│  1. JJ New → 2. Implement → 3. JJ Describe                  │
│                    ↓                                         │
│  4. /jj-analyze → 5. /adr extract → 6. /design-review       │
├─────────────────────────────────────────────────────────────┤
│  Phase 2: Release                                            │
├─────────────────────────────────────────────────────────────┤
│  7. /constraints-check → 8. /sync → 9. /pr → 10. Merge      │
│                    ↓                                         │
│  11. /release → 12. Push Tags                                │
└─────────────────────────────────────────────────────────────┘
```

### Scoring System

| Axis | Question | 0 | 3 |
|------|----------|---|---|
| Enforcement | Does breaking it break the system? | Optional | Critical |
| Scope | How far does it spread? | 1 file | Entire codebase |
| Recurrence | Will this come up again? | One-time | Daily |
| Rollback | Can we undo it? | Minutes | Full rewrite |

| Total | Action |
|-------|--------|
| 10-12 | Full ADR + CI enforcement |
| 7-9 | Light ADR |
| 4-6 | Design note |
| 0-3 | Skip |

---

## CI Integration

### GitHub Actions

```yaml
name: Architectural Compliance

on:
  pull_request:
    branches: [main]

jobs:
  check-constraints:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Claude Code
        run: npm install -g @anthropic-ai/claude-code

      - name: Check Constraints
        run: claude /constraints-check --ci
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
```

### Pre-commit Hook

```bash
#!/bin/bash
# .git/hooks/pre-commit

.adr-ai-skills/jj-workflow.sh validate || exit 1
claude /constraints-check staged --ci || exit 1
```

---

## Troubleshooting

### Plugin Not Recognized

```bash
# Check settings.json
cat .claude/settings.json | jq '.skills'

# Check CLAUDE.md
grep "adr-ai-skills" CLAUDE.md
```

### Conflicts with Existing Settings

The installer backs up existing files:

```bash
# Check backups
ls -la .claude/*.backup.*
ls -la CLAUDE.md.backup.*

# Restore if needed
cp .claude/settings.json.backup.20260117123456 .claude/settings.json
```

### JJ Not Installed

```bash
brew install jj   # macOS
cargo install jujutsu  # Others
```

ADR management works without JJ installed.

---

## Design Principles

1. **JJ is ephemeral** - Long-term info goes to ADRs
2. **ADRs freeze decisions** - OK to be wrong later; override with new ADR
3. **Constraints are enforced** - Machine-readable rules for CI
4. **Scoring provides restraint** - Don't ADR everything
5. **Humans have final say** - AI only suggests
6. **Don't break existing setups** - Merge and append
7. **Coexist with existing tools** - Import/export Nygard/MADR formats

---

## References

- [Architecture Decision Records](https://adr.github.io/)
- [adr-tools](https://github.com/npryce/adr-tools) - Michael Nygard's ADR tooling
- [MADR](https://github.com/adr/madr) - Markdown ADRs
- [log4brains](https://github.com/thomvaill/log4brains) - ADR management with web UI
- [Jujutsu VCS](https://github.com/martinvonz/jj)
- [Claude Code](https://docs.anthropic.com/claude-code)
- [Blog Articles](./docs/blog/)

## License

MIT
