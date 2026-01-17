#!/bin/bash
# JJ + ADR Workflow Helper Script
# Usage: ./tools/jj-workflow.sh <command> [args]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ADR_DIR="$PROJECT_ROOT/docs/adr"
CONSTRAINTS_FILE="$PROJECT_ROOT/docs/constraints.json"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

usage() {
    echo "JJ + ADR Workflow Helper"
    echo ""
    echo "Usage: $0 <command> [args]"
    echo ""
    echo "Commands:"
    echo "  status              Show current JJ and ADR status"
    echo "  recent [n]          Show recent JJ changes (default: 5)"
    echo "  adr-list            List all ADRs"
    echo "  adr-next            Show next ADR number"
    echo "  validate            Validate ADR format and constraints"
    echo "  init                Initialize ADR structure in current repo"
    echo ""
}

# Check if JJ is available
check_jj() {
    if ! command -v jj &> /dev/null; then
        echo -e "${YELLOW}Warning: JJ (Jujutsu) not found. JJ commands will be skipped.${NC}"
        return 1
    fi
    return 0
}

# Show current status
cmd_status() {
    echo -e "${BLUE}=== JJ + ADR Workflow Status ===${NC}"
    echo ""

    # JJ status
    if check_jj; then
        echo -e "${GREEN}JJ Status:${NC}"
        jj status 2>/dev/null || echo "  Not a JJ repository"
        echo ""
    fi

    # ADR count
    echo -e "${GREEN}ADR Status:${NC}"
    if [ -d "$ADR_DIR" ]; then
        adr_count=$(find "$ADR_DIR" -name "*.md" -type f | wc -l | tr -d ' ')
        echo "  Total ADRs: $adr_count"

        # Count by status
        accepted=$(grep -l "\[x\] Accepted" "$ADR_DIR"/*.md 2>/dev/null | wc -l | tr -d ' ')
        proposed=$(grep -l "\[x\] Proposed" "$ADR_DIR"/*.md 2>/dev/null | wc -l | tr -d ' ')
        echo "  Accepted: $accepted"
        echo "  Proposed: $proposed"
    else
        echo "  ADR directory not found"
    fi
    echo ""

    # Constraints
    echo -e "${GREEN}Constraints:${NC}"
    if [ -f "$CONSTRAINTS_FILE" ]; then
        rule_count=$(jq '.rules | length' "$CONSTRAINTS_FILE" 2>/dev/null || echo "error")
        echo "  Total rules: $rule_count"
    else
        echo "  constraints.json not found"
    fi
}

# Show recent JJ changes
cmd_recent() {
    local n=${1:-5}

    if ! check_jj; then
        return 1
    fi

    echo -e "${BLUE}=== Recent JJ Changes ===${NC}"
    jj log --limit "$n" -r 'all()' --no-graph -T 'change_id.short() ++ " " ++ description.first_line() ++ "\n"'
}

# List ADRs
cmd_adr_list() {
    echo -e "${BLUE}=== Architecture Decision Records ===${NC}"
    echo ""

    if [ ! -d "$ADR_DIR" ]; then
        echo "ADR directory not found: $ADR_DIR"
        return 1
    fi

    printf "%-10s %-40s %-8s %-10s\n" "ID" "Title" "Weight" "Status"
    printf "%s\n" "--------------------------------------------------------------------"

    for adr in "$ADR_DIR"/*.md; do
        if [ -f "$adr" ]; then
            # Extract info from ADR
            id=$(basename "$adr" .md | cut -d'-' -f1)
            title=$(head -1 "$adr" | sed 's/^# ADR-[0-9]*: //')
            weight=$(grep -A5 "Decision Weight" "$adr" | grep "Total:" | grep -oE '[0-9]+' | head -1)

            if grep -q "\[x\] Accepted" "$adr"; then
                status="Accepted"
            elif grep -q "\[x\] Proposed" "$adr"; then
                status="Proposed"
            elif grep -q "\[x\] Deprecated" "$adr"; then
                status="Deprecated"
            else
                status="Unknown"
            fi

            printf "%-10s %-40s %-8s %-10s\n" "$id" "${title:0:40}" "${weight:-N/A}" "$status"
        fi
    done
}

# Get next ADR number
cmd_adr_next() {
    if [ ! -d "$ADR_DIR" ]; then
        echo "0001"
        return
    fi

    last_num=$(ls "$ADR_DIR"/*.md 2>/dev/null | \
        xargs -I{} basename {} .md | \
        grep -oE '^[0-9]+' | \
        sort -n | tail -1)

    if [ -z "$last_num" ]; then
        echo "0001"
    else
        printf "%04d\n" $((10#$last_num + 1))
    fi
}

# Validate ADRs and constraints
cmd_validate() {
    echo -e "${BLUE}=== Validating ADR Structure ===${NC}"
    echo ""

    errors=0
    warnings=0

    # Check directory structure
    for dir in "$ADR_DIR" "$PROJECT_ROOT/docs/design-notes" "$PROJECT_ROOT/templates"; do
        if [ -d "$dir" ]; then
            echo -e "${GREEN}✓${NC} Directory exists: $dir"
        else
            echo -e "${RED}✗${NC} Missing directory: $dir"
            ((errors++))
        fi
    done

    # Check constraints.json
    if [ -f "$CONSTRAINTS_FILE" ]; then
        echo -e "${GREEN}✓${NC} constraints.json exists"

        # Validate JSON
        if jq empty "$CONSTRAINTS_FILE" 2>/dev/null; then
            echo -e "${GREEN}✓${NC} constraints.json is valid JSON"
        else
            echo -e "${RED}✗${NC} constraints.json is invalid JSON"
            ((errors++))
        fi
    else
        echo -e "${RED}✗${NC} Missing: constraints.json"
        ((errors++))
    fi

    # Validate ADR format
    echo ""
    echo "Checking ADR format..."
    for adr in "$ADR_DIR"/*.md; do
        if [ -f "$adr" ]; then
            name=$(basename "$adr")

            # Check required sections
            for section in "Context" "Decision" "Reason" "Consequences"; do
                if ! grep -q "## $section" "$adr"; then
                    echo -e "${YELLOW}⚠${NC} $name: Missing section '$section'"
                    ((warnings++))
                fi
            done

            # Check weight
            if ! grep -q "Decision Weight" "$adr"; then
                echo -e "${YELLOW}⚠${NC} $name: Missing Decision Weight"
                ((warnings++))
            fi
        fi
    done

    echo ""
    echo -e "${BLUE}Summary:${NC} $errors errors, $warnings warnings"

    if [ $errors -gt 0 ]; then
        return 1
    fi
    return 0
}

# Initialize ADR structure
cmd_init() {
    echo -e "${BLUE}=== Initializing ADR Structure ===${NC}"

    # Create directories
    mkdir -p "$ADR_DIR"
    mkdir -p "$PROJECT_ROOT/docs/design-notes"
    mkdir -p "$PROJECT_ROOT/templates"
    mkdir -p "$PROJECT_ROOT/tools/prompts"
    mkdir -p "$PROJECT_ROOT/skills"

    echo -e "${GREEN}✓${NC} Directories created"

    # Check if bootstrap ADR exists
    if [ ! -f "$ADR_DIR/0000-adr-process.md" ]; then
        echo -e "${YELLOW}Note:${NC} Bootstrap ADR (0000-adr-process.md) not found"
        echo "  Run the setup to create initial files"
    fi

    echo -e "${GREEN}✓${NC} Initialization complete"
}

# Main
case "${1:-}" in
    status)
        cmd_status
        ;;
    recent)
        cmd_recent "${2:-5}"
        ;;
    adr-list)
        cmd_adr_list
        ;;
    adr-next)
        cmd_adr_next
        ;;
    validate)
        cmd_validate
        ;;
    init)
        cmd_init
        ;;
    help|--help|-h)
        usage
        ;;
    *)
        usage
        exit 1
        ;;
esac
