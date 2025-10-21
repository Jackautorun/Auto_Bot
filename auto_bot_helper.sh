#!/usr/bin/env bash
# Auto_Bot Development Helper Script
# ใช้สำหรับการตั้งค่าและทดสอบ GitHub Actions workflows

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Repository settings
OWNER="Jackautorun"
REPO="Auto_Bot"
BASE_URL="https://api.github.com"

# Functions
print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  Auto_Bot Development Helper${NC}"
    echo -e "${BLUE}================================${NC}"
}

check_prerequisites() {
    echo -e "${YELLOW}Checking prerequisites...${NC}"
    
    if ! command -v gh &> /dev/null; then
        echo -e "${RED}❌ GitHub CLI (gh) not found${NC}"
        echo "Please install: https://cli.github.com/"
        exit 1
    fi
    
    if ! gh auth status &> /dev/null; then
        echo -e "${RED}❌ GitHub CLI not authenticated${NC}"
        echo "Please run: gh auth login"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Prerequisites OK${NC}"
}

setup_environment() {
    echo -e "${YELLOW}Setting up environment variables...${NC}"
    
    export OWNER="$OWNER"
    export REPO="$REPO"
    export AUTH="Bearer $(gh auth token)"
    export ACCEPT="application/vnd.github+json"
    export BASE="$BASE_URL"
    
    echo "OWNER=$OWNER"
    echo "REPO=$REPO"
    echo "AUTH=Bearer ***"
    echo "ACCEPT=$ACCEPT"
    echo "BASE=$BASE"
}

check_repository() {
    echo -e "${YELLOW}Checking repository status...${NC}"
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo -e "${RED}❌ Not in a git repository${NC}"
        echo "Run: gh repo clone $OWNER/$REPO"
        exit 1
    fi
    
    # Get current branch
    CURRENT_BRANCH=$(git branch --show-current)
    echo "Current branch: $CURRENT_BRANCH"
    
    # Check for uncommitted changes
    if ! git diff --quiet; then
        echo -e "${YELLOW}⚠️  Uncommitted changes detected${NC}"
    fi
    
    echo -e "${GREEN}✅ Repository status OK${NC}"
}

list_workflows() {
    echo -e "${YELLOW}Listing recent workflow runs...${NC}"
    gh run list --repo "$OWNER/$REPO" --limit 5 --json status,conclusion,name,createdAt
}

list_prs() {
    echo -e "${YELLOW}Listing open pull requests...${NC}"
    gh pr list --repo "$OWNER/$REPO" --state open
}

create_test_pr() {
    echo -e "${YELLOW}Creating test PR for current branch...${NC}"
    
    CURRENT_BRANCH=$(git branch --show-current)
    if [ "$CURRENT_BRANCH" = "main" ]; then
        echo -e "${RED}❌ Cannot create PR from main branch${NC}"
        exit 1
    fi
    
    gh pr create --repo "$OWNER/$REPO" \
        --title "test: automated PR from $CURRENT_BRANCH" \
        --body "Test PR created by development helper script" \
        --draft
}

show_help() {
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  check     - Check prerequisites and repository status"
    echo "  setup     - Setup environment variables"
    echo "  workflows - List recent workflow runs"
    echo "  prs       - List open pull requests" 
    echo "  test-pr   - Create test PR from current branch"
    echo "  help      - Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 check"
    echo "  $0 workflows"
    echo "  $0 test-pr"
}

# Main script logic
main() {
    print_header
    
    case "${1:-help}" in
        "check")
            check_prerequisites
            setup_environment
            check_repository
            ;;
        "setup")
            setup_environment
            ;;
        "workflows")
            setup_environment
            list_workflows
            ;;
        "prs")
            setup_environment
            list_prs
            ;;
        "test-pr")
            setup_environment
            check_repository
            create_test_pr
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

# Run main function with all arguments
main "$@"