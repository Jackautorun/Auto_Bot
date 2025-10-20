# Copilot Instructions for Auto_Bot

## Project Overview
Auto_Bot is a GitHub automation preset repository providing standardized CI/CD workflows and security tooling for GitHub repositories. This is primarily a configuration and automation project, not a traditional application codebase.

## Architecture & Purpose
- **Preset Collection**: Pre-configured GitHub Actions workflows for common automation needs
- **Multi-language Support**: Workflows designed to work across Python, Node.js, and other ecosystems
- **Security-First**: Includes CodeQL, secret scanning, and security workflow presets
- **LLM Evaluation**: Built-in support for AI model evaluation using promptfoo

## Key Components

### Workflow Templates (`.github/workflows/`)
- `ci.yml`: Python-focused CI with pytest, pip caching, and requirement file detection
- `codeql.yml`: GitHub's CodeQL security analysis
- `llm-eval.yml`: Scheduled LLM evaluation using promptfoo (requires `OPENAI_API_KEY`)
- `security.yml`: Comprehensive security scanning pipeline
- `release.yml`: Semantic versioning and automated releases

### Configuration Files
- `.releaserc.json`: Semantic-release configuration targeting `main` branch with changelog generation
- `promptfooconfig.yaml`: LLM evaluation setup with Thai language test cases
- `package.json`: Minimal Node.js package for tooling metadata

### Utility Scripts
- `scripts/list_workflow_runs.sh`: GitHub API client for monitoring workflow status
  - Requires environment variables: `AUTH`, `ACCEPT`, `BASE`, `OWNER`, `REPO`
  - Usage: `./list_workflow_runs.sh [per_page_count]` (default: 10)

## Developer Workflows

### Setup Process (per README)
1. Import all preset files into target repository
2. Enable GitHub Security features:
   - Secret scanning
   - Push protection
3. Configure secrets:
   - `OPENAI_API_KEY` (if using LLM evaluation)

### CI/CD Patterns
- **Python Projects**: Automatic detection of `requirements.txt` and `requirements-dev.txt`
- **Caching Strategy**: Pip cache with hash-based keys for performance
- **Security Integration**: CodeQL runs on pushes/PRs, security workflows include dependency scanning
- **Release Automation**: Conventional commits trigger semantic releases

### Monitoring & Debugging
- Use `scripts/list_workflow_runs.sh` for quick workflow status checks
- LLM eval runs weekly (Monday 6 AM UTC) via cron schedule
- All workflows include proper error handling and environment validation

## Project-Specific Conventions
- **Thai Language Support**: LLM evaluation includes Thai test cases and assertions
- **Environment Variables**: Strict validation with `set -euo pipefail` in bash scripts
- **Workflow Triggers**: Mix of push/PR triggers and manual dispatch for flexibility
- **Security Posture**: Push protection enabled, comprehensive scanning across multiple vectors

## Integration Points
- **GitHub API**: Direct integration via curl for workflow monitoring
- **OpenAI API**: LLM evaluation pipeline with configurable models
- **Semantic Release**: Automated changelog and version management
- **Multi-platform**: Designed to work across different repository types and languages

## Important Notes
- This is a **preset repository** - files are meant to be copied to other projects
- Workflows are designed to be robust with fallback behaviors (e.g., optional requirements files)
- Security workflows require proper GitHub repository settings to be effective
- LLM evaluation is optional but requires API key configuration