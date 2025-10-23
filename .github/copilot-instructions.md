# Copilot Instructions for Auto_Bot

## 🎯 Project Overview
Auto_Bot is a GitHub automation preset repository providing standardized CI/CD workflows and security tooling for GitHub repositories. This is a **configuration and automation project**, not a traditional application codebase.

## 🏗️ Architecture & Core Purpose
- **Preset Collection**: Pre-configured GitHub Actions workflows for common automation needs
- **Multi-language Support**: Workflows designed to work with Python, Node.js and other ecosystems
- **Security-First Approach**: Includes CodeQL, secret scanning and security workflow presets
- **LLM Evaluation Pipeline**: Support for AI model evaluation using promptfoo (with Thai language support)

## 📁 Key Components

### Workflow Templates (`.github/workflows/`)
```yaml
ci.yml           # Python CI with pytest, pip caching, requirements detection
codeql.yml       # GitHub CodeQL security analysis
llm-eval.yml     # Scheduled LLM evaluation (Mondays 6:00 UTC)
security.yml     # Comprehensive security scanning
release.yml      # Semantic versioning + automated releases
auto-approve-*.yml # Automated PR approval workflows
```

### Configuration Files
- **`.releaserc.json`**: Semantic-release config → `main` branch, changelog generation
- **`promptfooconfig.yaml`**: LLM eval setup with Thai language test cases
- **`package.json`**: Minimal Node.js package for tooling metadata

### Utility Scripts
- **`scripts/list_workflow_runs.sh`**: GitHub API client for monitoring workflow status
  - Required environment variables: `AUTH`, `ACCEPT`, `BASE`, `OWNER`, `REPO`
  - Usage: `./list_workflow_runs.sh [per_page_count]` (default: 10)
- **`Auto_Bot_Helper.ps1`**: PowerShell automation for bulk PR creation and management
- **`auto_bot_helper.sh`**: Bash equivalent automation script

## 📄 Developer Workflows

### Setup Process (from README)
1. Import preset files to target repository
2. Enable GitHub Security features:
   - Secret scanning
   - Push protection
3. Configure secrets:
   - `OPENAI_API_KEY` (if using LLM evaluation)

### CI/CD Patterns
- **Python Projects**: Auto-detect `requirements.txt` and `requirements-dev.txt`
- **Caching Strategy**: Pip cache with hash-based keys for performance
- **Security Integration**: CodeQL runs on pushes/PRs, security workflows include dependency scanning
- **Release Automation**: Conventional commits trigger semantic releases automatically

### Monitoring & Debugging
```bash
# Quick workflow status check
./scripts/list_workflow_runs.sh 5

# LLM eval schedule
# - Runs every Monday 6:00 UTC via cron
# - Manual dispatch available
```

## 🔧 Project-Specific Conventions

### Thai Language Integration
- LLM evaluation supports Thai test cases and assertions
- Example test: `{ input: "สรุปหัวข้อประชุม 5 บรรทัด" }`
- Assert pattern: `{ type: contains, value: "สรุป" }`

### Error Handling Patterns
- **Bash Scripts**: Use `set -euo pipefail` as standard
- **Environment Validation**: Strict validation with `${VAR:?message}` pattern
- **Workflow Fallbacks**: Optional requirements files, graceful degradation

### Trigger Strategy
- **Push/PR**: `main` branch and PR events
- **Manual Dispatch**: `workflow_dispatch` for manual control
- **Scheduled**: Cron-based for periodic tasks (LLM eval)

### Auto-Approval System
- **Bulk PR Creation**: Helper scripts can create multiple PRs for testing
- **Automated Approval**: Workflows handle auto-approval and merging
- **Branch Naming**: Uses patterns like `feat/auto-YYYYMMDD-HHMMSS` and `auto/bulk-N-HHMMSS`

## 🔌 Integration Points

### External APIs
- **GitHub API**: Direct curl integration for workflow monitoring
- **OpenAI API**: LLM evaluation pipeline with configurable models
- **Semantic Release**: Automated changelog and version management

### Cross-Repository Usage
- Files designed to be copied to other projects
- Workflows have fallback behaviors (e.g., optional requirements files)
- Security workflows require proper GitHub repository settings

## ⚠️ Critical Notes for AI Agents

### Repository Nature
- **This is a PRESET REPOSITORY** - files are designed to be copied to other projects
- Not a traditional application - it's configuration and automation tooling

### Dependencies & Requirements
- Security workflows require appropriate GitHub repository settings
- LLM evaluation is optional but requires API key configuration
- Python workflows detect requirements files automatically

### Best Practices
- Use conventional commits for proper semantic releases
- Monitor workflow status using provided scripts
- Validate environment variables before deployment
- Check security settings after importing presets

### Helper Script Usage
```powershell
# PowerShell automation
. .\Auto_Bot_Helper.ps1
New-AutoPR -Title "feat: new feature" -Body "Description"
Invoke-BulkPRs -Count 5
```

```bash
# Bash automation
source ./auto_bot_helper.sh
# Functions available for PR automation
```

## 🚀 Quick Start Commands
```bash
# Clone and setup
git clone https://github.com/Jackautorun/Auto_Bot.git
cd Auto_Bot

# Monitor workflows
export AUTH="Bearer YOUR_TOKEN"
export ACCEPT="application/vnd.github+json"
export BASE="https://api.github.com"
export OWNER="YOUR_OWNER"
export REPO="YOUR_REPO"
./scripts/list_workflow_runs.sh

# Test LLM evaluation locally
promptfoo eval --config promptfooconfig.yaml

# Bulk PR testing (PowerShell)
. .\Auto_Bot_Helper.ps1; Invoke-BulkPRs -Count 3
```

## 🏗️ Architecture & Core Purpose
- **Preset Collection**: Pre-configured GitHub Actions workflows สำหรับความต้องการ automation ทั่วไป
- **Multi-language Support**: Workflows ที่ออกแบบให้ทำงานกับ Python, Node.js และ ecosystems อื่นๆ
- **Security-First Approach**: รวม CodeQL, secret scanning และ security workflow presets
- **LLM Evaluation Pipeline**: รองรับการประเมิน AI model ด้วย promptfoo (รองรับภาษาไทย)

## 📁 Key Components

### Workflow Templates (`.github/workflows/`)
```yaml
ci.yml           # Python CI ด้วย pytest, pip caching, requirements detection
codeql.yml       # GitHub CodeQL security analysis  
llm-eval.yml     # Scheduled LLM evaluation (จันทร์ 6:00 UTC)
security.yml     # Comprehensive security scanning
release.yml      # Semantic versioning + automated releases
```

### Configuration Files
- **`.releaserc.json`**: Semantic-release config → `main` branch, changelog generation
- **`promptfooconfig.yaml`**: LLM eval setup พร้อม Thai language test cases
- **`package.json`**: Minimal Node.js package สำหรับ tooling metadata

### Utility Scripts
- **`scripts/list_workflow_runs.sh`**: GitHub API client สำหรับ monitoring workflow status
  - Environment variables ที่จำเป็น: `AUTH`, `ACCEPT`, `BASE`, `OWNER`, `REPO`
  - การใช้งาน: `./list_workflow_runs.sh [per_page_count]` (default: 10)

## 🔄 Developer Workflows

### Setup Process (ตาม README)
1. Import preset files ทั้งหมดไปยัง target repository
2. เปิดใช้งาน GitHub Security features:
   - Secret scanning
   - Push protection  
3. ตั้งค่า secrets:
   - `OPENAI_API_KEY` (หากใช้ LLM evaluation)

### CI/CD Patterns ที่สำคัญ
- **Python Projects**: Auto-detect `requirements.txt` และ `requirements-dev.txt`
- **Caching Strategy**: Pip cache พร้อม hash-based keys เพื่อ performance
- **Security Integration**: CodeQL ทำงานบน pushes/PRs, security workflows รวม dependency scanning
- **Release Automation**: Conventional commits จะ trigger semantic releases อัตโนมัติ

### Monitoring & Debugging
```bash
# ตรวจสอบสถานะ workflow อย่างรวดเร็ว
./scripts/list_workflow_runs.sh 5

# LLM eval schedule
# - ทำงานทุกวันจันทร์ 6:00 UTC ผ่าน cron
# - Manual dispatch พร้อมใช้งาน
```

## 🔧 Project-Specific Conventions

### Thai Language Integration
- LLM evaluation รองรับ Thai test cases และ assertions
- ตัวอย่าง test: `{ input: "สรุปหัวข้อประชุม 5 บรรทัด" }`
- Assert pattern: `{ type: contains, value: "สรุป" }`

### Error Handling Patterns
- **Bash Scripts**: ใช้ `set -euo pipefail` เป็น standard
- **Environment Validation**: Strict validation ด้วย `${VAR:?message}` pattern
- **Workflow Fallbacks**: Optional requirements files, graceful degradation

### Trigger Strategy
- **Push/PR**: `main` branch และ PR events
- **Manual Dispatch**: `workflow_dispatch` สำหรับ manual control
- **Scheduled**: Cron-based สำหรับ periodic tasks (LLM eval)

## 🔌 Integration Points

### External APIs
- **GitHub API**: Direct curl integration สำหรับ workflow monitoring
- **OpenAI API**: LLM evaluation pipeline พร้อม configurable models
- **Semantic Release**: Automated changelog และ version management

### Cross-Repository Usage
- Files ออกแบบให้ copy ไปใช้ใน projects อื่น
- Workflows มี fallback behaviors (เช่น optional requirements files)
- Security workflows ต้องการ proper GitHub repository settings

## ⚠️ Critical Notes for AI Agents

### Repository Nature
- **นี่คือ PRESET REPOSITORY** - files ถูกออกแบบให้ copy ไปใช้ใน projects อื่น
- ไม่ใช่ traditional application - เป็น configuration และ automation tooling

### Dependencies & Requirements  
- Security workflows ต้องการ GitHub repository settings ที่เหมาะสม
- LLM evaluation เป็น optional แต่ต้องการ API key configuration
- Python workflows detect requirements files อัตโนมัติ

### Best Practices
- ใช้ conventional commits สำหรับ proper semantic releases
- Monitor workflow status ด้วย provided scripts
- Validate environment variables ก่อน deployment
- ตรวจสอบ security settings หลัง import presets

## 🚀 Quick Start Commands
```bash
# Clone และ setup
git clone https://github.com/Jackautorun/Auto_Bot.git
cd Auto_Bot

# Monitor workflows  
export AUTH="Bearer YOUR_TOKEN"
export ACCEPT="application/vnd.github+json"
export BASE="https://api.github.com"
export OWNER="YOUR_OWNER"
export REPO="YOUR_REPO"
./scripts/list_workflow_runs.sh

# Test LLM evaluation locally
promptfoo eval --config promptfooconfig.yaml
```