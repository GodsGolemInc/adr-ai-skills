#!/bin/bash
# ADR AI Skills - Uninstaller
# Safely removes plugin while preserving user data

set -e

PLUGIN_NAME="adr-ai-skills"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Target directory
TARGET_DIR="${1:-.}"
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║  ${BLUE}ADR AI Skills${CYAN} - Uninstaller                            ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "Target: ${GREEN}$TARGET_DIR${NC}"
echo ""

# Check if installed
if [ ! -d "$TARGET_DIR/.adr-ai-skills" ]; then
    echo -e "${YELLOW}Plugin not found in $TARGET_DIR${NC}"
    exit 1
fi

echo -e "${YELLOW}Warning: This will remove the ADR AI Skills plugin.${NC}"
echo ""
echo "The following will be REMOVED:"
echo "  - .adr-ai-skills/ directory"
echo "  - Plugin section from CLAUDE.md"
echo "  - Plugin skills from .claude/settings.json"
echo ""
echo "The following will be PRESERVED:"
echo "  - docs/adr/ (your ADRs)"
echo "  - docs/design-notes/"
echo "  - docs/constraints.json"
echo ""

read -p "Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

echo ""
echo -e "${BLUE}[1/3]${NC} Removing plugin directory..."

rm -rf "$TARGET_DIR/.adr-ai-skills"
echo -e "  ${GREEN}✓${NC} Removed .adr-ai-skills/"

echo -e "${BLUE}[2/3]${NC} Cleaning CLAUDE.md..."

if [ -f "$TARGET_DIR/CLAUDE.md" ]; then
    # Create backup
    cp "$TARGET_DIR/CLAUDE.md" "$TARGET_DIR/CLAUDE.md.backup.$(date +%Y%m%d%H%M%S)"

    if grep -q "BEGIN adr-ai-skills plugin" "$TARGET_DIR/CLAUDE.md"; then
        sed '/<!-- BEGIN adr-ai-skills plugin -->/,/<!-- END adr-ai-skills plugin -->/d' \
            "$TARGET_DIR/CLAUDE.md" > "$TARGET_DIR/CLAUDE.md.tmp"
        mv "$TARGET_DIR/CLAUDE.md.tmp" "$TARGET_DIR/CLAUDE.md"
        echo -e "  ${GREEN}✓${NC} Removed plugin section from CLAUDE.md"
    else
        echo -e "  ${YELLOW}⊘${NC} No plugin section found in CLAUDE.md"
    fi
fi

echo -e "${BLUE}[3/3]${NC} Cleaning settings.json..."

if [ -f "$TARGET_DIR/.claude/settings.json" ]; then
    if command -v jq &> /dev/null; then
        # Backup
        cp "$TARGET_DIR/.claude/settings.json" "$TARGET_DIR/.claude/settings.json.backup.$(date +%Y%m%d%H%M%S)"

        # Remove adr-ai-skills skills
        jq 'del(
            .skills["adr-ai-skills:adr"],
            .skills["adr-ai-skills:jj-analyze"],
            .skills["adr-ai-skills:design-review"],
            .skills["adr-ai-skills:constraints-check"],
            .skills["adr-ai-skills:sync"],
            .skills["adr-ai-skills:pr"],
            .skills["adr-ai-skills:release"]
        )' "$TARGET_DIR/.claude/settings.json" > "$TARGET_DIR/.claude/settings.json.tmp"
        mv "$TARGET_DIR/.claude/settings.json.tmp" "$TARGET_DIR/.claude/settings.json"

        echo -e "  ${GREEN}✓${NC} Removed plugin skills from settings.json"
    else
        echo -e "  ${YELLOW}⚠${NC} jq not found - manual cleanup required"
        echo "      Remove adr-ai-skills:* entries from .claude/settings.json"
    fi
fi

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Uninstallation Complete!                                ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Your ADRs and constraints have been preserved in doc/"
echo ""
echo "Backup files created with .backup.* extension"
echo "You can safely delete them after verification."
