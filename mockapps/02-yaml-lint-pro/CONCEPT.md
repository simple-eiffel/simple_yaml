# YAML Lint Pro (yaml-lint)

## Executive Summary

YAML Lint Pro is a professional-grade YAML linting and validation CLI tool that goes beyond basic syntax checking. It provides customizable rule engines, schema validation, best-practice enforcement, and seamless CI/CD integration.

The tool addresses the gap between basic YAML validators that only check syntax and full-blown configuration management systems. Development teams need a lightweight, fast linting tool that can catch configuration errors before they cause production incidents, enforce organizational standards, and integrate into pre-commit hooks and CI pipelines.

Built with Design by Contract principles, YAML Lint Pro itself is a showcase of contract-driven development, providing detailed explanations when validation fails and offering suggestions for fixes.

## Problem Statement

**The problem:** YAML configuration errors are a leading cause of deployment failures, with issues including:
- Syntax errors that slip through code review
- Inconsistent formatting across teams
- Schema violations discovered only at runtime
- Best practice violations (security, performance)
- No standardized validation across projects

**Current solutions:**
- Online validators (YAMLlint.com) - no CI integration, privacy concerns
- Generic linters (yamllint) - limited customization, no schema support
- IDE plugins - not CI-friendly, inconsistent across editors
- Custom scripts - unmaintainable, team-specific

**Our approach:**
- Professional CLI with comprehensive rule engine
- Custom rule builder for organization-specific policies
- JSON Schema validation for structural requirements
- Pre-configured rule sets for Kubernetes, Docker, CI/CD
- Machine-readable output for automation
- Zero dependencies, single binary deployment

## Target Users

| User Type | Description | Key Needs |
|-----------|-------------|-----------|
| Primary: DevOps Engineer | CI/CD pipeline maintainer | Pipeline integration, fast feedback, actionable errors |
| Primary: Platform Engineer | Infrastructure standards owner | Custom rules, policy enforcement, audit reports |
| Secondary: Developer | Application config author | Pre-commit validation, IDE-like feedback |
| Secondary: QA Engineer | Quality gate owner | Report generation, metrics tracking |

## Value Proposition

**For** development teams and platform engineers
**Who** need to validate YAML configurations before deployment
**This app** provides professional linting with custom rules and schema validation
**Unlike** online validators or basic linters
**We** offer CI/CD-native integration, organization-specific rule sets, and contract-verified validation built on the reliable simple_* ecosystem.

## Revenue Model

| Model | Description | Price Point |
|-------|-------------|-------------|
| Community Edition | Core linting, built-in rules | Free / Open Source |
| Pro Edition | Custom rule builder, rule sharing, priority rules | $99/year per user |
| Team Edition | Shared rule repository, team analytics | $249/year per team (5 users) |
| Enterprise Edition | On-premise rule server, SSO, audit logs | $999/year per team |

## Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Lint speed | < 50ms per file | Benchmark tests |
| Rule coverage | 50+ built-in rules | Rule catalog count |
| CI integrations | GitHub, GitLab, Azure, Jenkins | Integration docs |
| Community adoption | 2000+ GitHub stars | GitHub metrics |
| Pro conversions | 5% of community users | License sales |

## Core Features

### Basic Linting
```bash
yaml-lint file.yml                      # Lint single file
yaml-lint *.yml                         # Lint multiple files
yaml-lint --config .yamllint.yml src/   # Lint directory with config
yaml-lint --stdin < config.yml          # Lint from stdin
```

### Rule Configuration
```bash
yaml-lint rules list                    # List all available rules
yaml-lint rules show indent             # Show rule details
yaml-lint rules enable no-duplicate-keys  # Enable rule
yaml-lint rules disable trailing-spaces   # Disable rule
yaml-lint rules create my-rule          # Create custom rule
```

### Schema Validation
```bash
yaml-lint --schema schema.json file.yml # Validate against JSON Schema
yaml-lint --schema kubernetes file.yml  # Use built-in K8s schema
yaml-lint --schema docker-compose file.yml # Use Docker Compose schema
```

### CI/CD Integration
```bash
yaml-lint --format json                 # JSON output for parsing
yaml-lint --format github-actions       # GitHub Actions annotation format
yaml-lint --format gitlab-ci            # GitLab CI report format
yaml-lint --format checkstyle           # Checkstyle XML format
yaml-lint --exit-zero                   # Always exit 0 (for warnings)
```

### Reporting
```bash
yaml-lint --report summary              # Summary statistics
yaml-lint --report detailed             # Full violation report
yaml-lint --report sarif                # SARIF format for security tools
yaml-lint --fix                         # Auto-fix safe violations
```

## Built-in Rule Categories

### Syntax Rules
- `valid-yaml`: File is valid YAML
- `no-tabs`: No tab characters
- `no-trailing-spaces`: No trailing whitespace
- `newline-at-eof`: File ends with newline

### Formatting Rules
- `indent`: Consistent indentation (2 or 4 spaces)
- `line-length`: Maximum line length
- `key-ordering`: Alphabetical or custom key order
- `quote-style`: Consistent quote usage

### Structure Rules
- `no-duplicate-keys`: No duplicate mapping keys
- `no-empty-values`: No empty string values
- `required-keys`: Enforce required keys present
- `max-depth`: Maximum nesting depth

### Best Practice Rules
- `no-hardcoded-secrets`: Detect password/token patterns
- `lowercase-keys`: Enforce lowercase key names
- `no-anchor-alias`: Disallow anchors/aliases
- `explicit-types`: Require explicit type tags

### Domain-Specific Rules
- `k8s-valid-kind`: Valid Kubernetes resource kinds
- `docker-compose-version`: Valid Compose version
- `github-actions-valid`: Valid GitHub Actions structure

## Competitive Advantages

1. **Contract-Driven:** Every rule has documented preconditions, postconditions, and invariants.

2. **Fast Execution:** Single binary, no interpreter, optimized parsing.

3. **Custom Rules:** DSL for organization-specific policies without coding.

4. **Schema Integration:** First-class JSON Schema support for structural validation.

5. **CI-Native:** Purpose-built output formats for major CI/CD platforms.

6. **Privacy First:** All validation local, no data sent to external services.
