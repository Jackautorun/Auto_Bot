#!/usr/bin/env bash
# Validation script for Auto_Bot v2 project
# This script validates all components of the Auto_Bot repository

set -euo pipefail

echo "================================"
echo "  Auto_Bot v2 Validation"
echo "================================"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS=0
FAIL=0

check() {
    local name="$1"
    shift
    echo -n "  $name... "
    if "$@" &>/dev/null; then
        echo -e "${GREEN}✓${NC}"
        PASS=$((PASS + 1))
    else
        echo -e "${RED}✗${NC}"
        FAIL=$((FAIL + 1))
    fi
}

echo "1. Checking file structure..."
check "README.md exists" test -f README.md
check "promptfooconfig.yaml exists" test -f promptfooconfig.yaml
check "package.json exists" test -f package.json
check "Helper scripts exist" test -f auto_bot_helper.sh -a -f Auto_Bot_Helper.ps1
check "Workflow scripts exist" test -f scripts/list_workflow_runs.sh
echo ""

echo "2. Checking file permissions..."
check "auto_bot_helper.sh is executable" test -x auto_bot_helper.sh
check "Auto_Bot_Helper.ps1 is executable" test -x Auto_Bot_Helper.ps1
check "list_workflow_runs.sh is executable" test -x scripts/list_workflow_runs.sh
echo ""

echo "3. Validating YAML files..."
for f in .github/workflows/*.yml promptfooconfig.yaml; do
    check "$(basename $f) is valid YAML" python3 -c "import yaml; yaml.safe_load(open('$f'))"
done
echo ""

echo "4. Validating shell scripts..."
check "auto_bot_helper.sh syntax" bash -n auto_bot_helper.sh
check "list_workflow_runs.sh syntax" bash -n scripts/list_workflow_runs.sh
echo ""

echo "5. Checking README content..."
check "README has no corrupted text" bash -c "! grep -q '\x00' README.md"
check "README has proper sections" grep -q "## ✨ คุณสมบัติหลัก" README.md
check "README has installation guide" grep -q "## 🚀 การติดตั้ง" README.md
check "README has usage section" grep -q "## 📋 การใช้งาน" README.md
echo ""

echo "================================"
echo "  Validation Summary"
echo "================================"
echo -e "  ${GREEN}Passed: $PASS${NC}"
echo -e "  ${RED}Failed: $FAIL${NC}"
echo ""

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}✓ All validations passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some validations failed${NC}"
    exit 1
fi
