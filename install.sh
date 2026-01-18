#!/bin/bash
# ADR AI Skills - Installer
# AI-Enhanced Architecture Decision Records
# Safe installation that preserves existing configuration

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_NAME="adr-ai-skills"
VERSION="1.0.0"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Target directory (default: current directory)
TARGET_DIR="${1:-.}"

echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                                                          ║${NC}"
echo -e "${CYAN}║   ${BLUE}ADR AI Skills${CYAN} - AI-Enhanced ADR Management           ║${NC}"
echo -e "${CYAN}║   Version ${VERSION}                                          ║${NC}"
echo -e "${CYAN}║                                                          ║${NC}"
echo -e "${CYAN}║   ${NC}Detect • Generate • Enforce${CYAN}                           ║${NC}"
echo -e "${CYAN}║                                                          ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Resolve target directory
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"
echo -e "Target: ${GREEN}$TARGET_DIR${NC}"
echo ""

# Check if already installed
if [ -d "$TARGET_DIR/.adr-ai-skills" ]; then
    echo -e "${YELLOW}Warning: Plugin already installed.${NC}"
    read -p "Reinstall? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
    echo -e "Backing up existing installation..."
    mv "$TARGET_DIR/.adr-ai-skills" "$TARGET_DIR/.adr-ai-skills.backup.$(date +%Y%m%d%H%M%S)"
fi

echo -e "${BLUE}[1/7]${NC} Creating directory structure..."

# Create directories (safe - mkdir -p won't fail if exists)
mkdir -p "$TARGET_DIR/.adr-ai-skills/templates"
mkdir -p "$TARGET_DIR/.adr-ai-skills/prompts"
mkdir -p "$TARGET_DIR/.claude/skills"
mkdir -p "$TARGET_DIR/docs/adr"
mkdir -p "$TARGET_DIR/docs/design-notes"

echo -e "  ${GREEN}✓${NC} Directories created"

echo -e "${BLUE}[2/7]${NC} Installing skills (Claude Code official format)..."

# Source directory for plugin files
SOURCE_DIR="$SCRIPT_DIR"

# Copy skills to .claude/skills/ (official Claude Code format)
for skill in adr jj-analyze design-review constraints-check sync pr release; do
    mkdir -p "$TARGET_DIR/.claude/skills/$skill"
    if [ -f "$SOURCE_DIR/.claude/skills/$skill/SKILL.md" ]; then
        cp "$SOURCE_DIR/.claude/skills/$skill/SKILL.md" "$TARGET_DIR/.claude/skills/$skill/"
    fi
done

echo -e "  ${GREEN}✓${NC} Skills installed"

echo -e "${BLUE}[3/7]${NC} Installing plugin files..."

# Copy plugin files to .adr-ai-skills (prompts, templates)
cp "$SOURCE_DIR/.adr-ai-skills/plugin.json" "$TARGET_DIR/.adr-ai-skills/"
cp "$SOURCE_DIR/.adr-ai-skills/templates/"*.md "$TARGET_DIR/.adr-ai-skills/templates/" 2>/dev/null || true
cp "$SOURCE_DIR/.adr-ai-skills/prompts/"*.md "$TARGET_DIR/.adr-ai-skills/prompts/" 2>/dev/null || true
cp "$SOURCE_DIR/.adr-ai-skills/jj-workflow.sh" "$TARGET_DIR/.adr-ai-skills/" 2>/dev/null || true
chmod +x "$TARGET_DIR/.adr-ai-skills/jj-workflow.sh" 2>/dev/null || true

echo -e "  ${GREEN}✓${NC} Plugin files installed"

echo -e "${BLUE}[4/7]${NC} Setting up constraints..."

# Create constraints.json if not exists
if [ ! -f "$TARGET_DIR/docs/constraints.json" ]; then
    cat > "$TARGET_DIR/docs/constraints.json" << 'EOF'
{
  "$schema": "./constraints-schema.json",
  "version": "1.0.0",
  "lastUpdated": "INSTALL_DATE",
  "rules": [],
  "metadata": {
    "extractedFrom": "docs/adr/",
    "totalADRs": 0,
    "criticalRules": 0
  }
}
EOF
    sed -i.bak "s/INSTALL_DATE/$(date +%Y-%m-%d)/" "$TARGET_DIR/docs/constraints.json"
    rm -f "$TARGET_DIR/docs/constraints.json.bak"
    echo -e "  ${GREEN}✓${NC} Created constraints.json"
else
    echo -e "  ${YELLOW}⊘${NC} constraints.json already exists (preserved)"
fi

# Copy schema if not exists
if [ ! -f "$TARGET_DIR/docs/constraints-schema.json" ]; then
    cp "$SOURCE_DIR/.adr-ai-skills/constraints-schema.json" "$TARGET_DIR/docs/" 2>/dev/null || true
    echo -e "  ${GREEN}✓${NC} Created constraints-schema.json"
else
    echo -e "  ${YELLOW}⊘${NC} constraints-schema.json already exists (preserved)"
fi

echo -e "${BLUE}[5/7]${NC} Configuring Claude Code..."

# Skills are auto-discovered from .claude/skills/*/SKILL.md
# No need to modify settings.json for skills

mkdir -p "$TARGET_DIR/.claude"

if [ ! -f "$TARGET_DIR/.claude/settings.json" ]; then
    # Create minimal settings.json if not exists
    cat > "$TARGET_DIR/.claude/settings.json" << 'EOF'
{
  "prompts": {
    "architect": {
      "system": "You are a software architect. Ensure code changes respect existing ADRs."
    }
  }
}
EOF
    echo -e "  ${GREEN}✓${NC} Created settings.json"
else
    echo -e "  ${YELLOW}⊘${NC} settings.json exists (preserved)"
fi

echo -e "  ${GREEN}✓${NC} Skills auto-discovered from .claude/skills/"

echo -e "${BLUE}[6/7]${NC} Updating CLAUDE.md..."

# Append to CLAUDE.md (not replace)
CLAUDE_SECTION=$(cat << 'EOF'

<!-- BEGIN adr-ai-skills plugin -->
## ADR AI Skills

**AI-Enhanced Architecture Decision Records** - Detect, generate, and enforce ADRs with AI.

### What's Different from Traditional ADR Tools?

| Traditional ADR Tools | ADR AI Skills |
|----------------------|---------------|
| Manual ADR writing | AI detects & generates ADRs |
| No enforcement | CI constraint checking |
| Format lock-in | Multi-format support |
| Separate from workflow | Integrated with JJ/Git/PR |

### Skills

| Command | Description |
|---------|-------------|
| `/adr list` | List all ADRs |
| `/adr new [title]` | Create new ADR (AI-assisted) |
| `/adr extract [jj-id]` | Extract ADR from code changes |
| `/adr export --format nygard` | Export to other formats |
| `/jj-analyze` | Detect architectural decisions |
| `/design-review` | AI compliance review |
| `/constraints-check` | Validate against ADR rules |
| `/sync` | Sync to Git |
| `/pr` | Create PR with ADR links |
| `/release` | Release with ADR notes |

### Format Compatibility

| Format | Compatible Tools | Import | Export |
|--------|-----------------|--------|--------|
| Extended | ADR AI Skills | ✓ | ✓ |
| Nygard | adr-tools | ✓ | ✓ |
| MADR | madr, log4brains | ✓ | ✓ |

### Workflow

```
Code Change → AI Detection → ADR Generation → Constraint Extraction → CI Enforcement
```
<!-- END adr-ai-skills plugin -->
EOF
)

if [ -f "$TARGET_DIR/CLAUDE.md" ]; then
    # Check if already added
    if grep -q "BEGIN adr-ai-skills plugin" "$TARGET_DIR/CLAUDE.md"; then
        echo -e "  ${YELLOW}⊘${NC} CLAUDE.md already contains plugin section"
    else
        echo "$CLAUDE_SECTION" >> "$TARGET_DIR/CLAUDE.md"
        echo -e "  ${GREEN}✓${NC} Appended to CLAUDE.md"
    fi
else
    echo "# Project Configuration" > "$TARGET_DIR/CLAUDE.md"
    echo "$CLAUDE_SECTION" >> "$TARGET_DIR/CLAUDE.md"
    echo -e "  ${GREEN}✓${NC} Created CLAUDE.md"
fi

# Initialize VCS if not already initialized
if [ ! -d "$TARGET_DIR/.jj" ] && [ ! -d "$TARGET_DIR/.git" ]; then
    echo ""
    echo -e "${BLUE}[7/7]${NC} Initializing version control..."
    if command -v jj &> /dev/null; then
        # JJ available - use colocated mode (JJ + Git)
        jj git init --colocate "$TARGET_DIR"
        echo -e "  ${GREEN}✓${NC} Initialized JJ (colocated with Git)"
    elif command -v git &> /dev/null; then
        # Fallback to Git only
        git init "$TARGET_DIR"
        echo -e "  ${YELLOW}⊘${NC} Initialized Git (JJ not found - recommend: brew install jj)"
    else
        echo -e "  ${YELLOW}⚠${NC} No VCS found - manual initialization required"
    fi
elif [ -d "$TARGET_DIR/.git" ] && [ ! -d "$TARGET_DIR/.jj" ]; then
    echo ""
    echo -e "${BLUE}[7/7]${NC} Version control setup..."
    if command -v jj &> /dev/null; then
        echo -e "  ${YELLOW}⊘${NC} Git repo exists. To add JJ: jj git init --git-repo ."
    else
        echo -e "  ${YELLOW}⊘${NC} Git repo exists (JJ not installed)"
    fi
else
    echo ""
    echo -e "${BLUE}[7/7]${NC} Version control..."
    echo -e "  ${GREEN}✓${NC} Already initialized"
fi

# Create bootstrap ADR if docs/adr is empty
if [ -z "$(ls -A "$TARGET_DIR/docs/adr" 2>/dev/null)" ]; then
    cat > "$TARGET_DIR/docs/adr/0000-adr-process.md" << 'EOF'
# ADR-0000: ADR Process Adopted

## Origin
- JJ Change: N/A (bootstrap)
- Date: INSTALL_DATE

## Decision Weight
- Enforcement: 3
- Scope: 3
- Recurrence: 3
- Rollback Cost: 2
- Total: 11

## Context
This project requires systematic capture of architectural decisions.

## Decision
Adopt ADR (Architecture Decision Record) format with AI-assisted detection and generation.

## Reason
- Preserves "why" context
- AI detects decisions automatically from code changes
- Machine-readable constraints enable CI enforcement
- Compatible with existing ADR tools (adr-tools, MADR)

## Consequences
### Benefits
- Design decisions are searchable
- AI reduces documentation burden
- CI prevents accidental violations
- Works with existing ADR ecosystem

### Trade-offs
- Requires Claude Code for AI features

## Status
- [x] Accepted
EOF
    sed -i.bak "s/INSTALL_DATE/$(date +%Y-%m-%d)/" "$TARGET_DIR/docs/adr/0000-adr-process.md"
    rm -f "$TARGET_DIR/docs/adr/0000-adr-process.md.bak"
    echo -e "  ${GREEN}✓${NC} Created bootstrap ADR"
fi

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Installation Complete!                                  ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "Installed: ${CYAN}ADR AI Skills v${VERSION}${NC}"
echo -e "Location:  ${GREEN}$TARGET_DIR${NC}"
echo ""
echo -e "${BLUE}Quick Start:${NC}"
echo "  1. cd $TARGET_DIR"
echo "  2. claude"
echo "  3. /adr list"
echo ""
echo -e "${BLUE}Key Features:${NC}"
echo "  • AI detection of architectural decisions"
echo "  • Multi-format support (Nygard, MADR)"
echo "  • CI constraint enforcement"
echo ""
echo -e "${BLUE}Uninstall:${NC}"
echo "  $SCRIPT_DIR/uninstall.sh $TARGET_DIR"
