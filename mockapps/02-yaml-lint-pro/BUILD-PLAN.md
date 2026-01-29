# YAML Lint Pro - Build Plan

## Phase Overview

| Phase | Deliverable | Effort | Dependencies |
|-------|-------------|--------|--------------|
| Phase 1 | MVP CLI (basic linting) | 4 days | simple_yaml, simple_cli, simple_file |
| Phase 2 | Full CLI (rules, schemas, fix) | 6 days | Phase 1 + simple_json, simple_regex |
| Phase 3 | Polish (CI formats, performance) | 4 days | Phase 2 |

---

## Phase 1: MVP

### Objective

Create a functional linting CLI that can parse YAML files, apply basic built-in rules, and report violations. This MVP demonstrates the rule engine architecture and proves market fit.

### Deliverables

1. **LINT_CLI** - Main CLI entry point
2. **LINT_ENGINE** - Core linting orchestration
3. **LINT_CONTEXT** - File context for rules
4. **LINT_RESULT** - Violation collection
5. **LINT_RULE** - Base rule class
6. **Basic rules:** valid-yaml, indent, no-duplicate-keys, line-length, trailing-spaces
7. **Basic output:** text format with colors

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T1.1 | Project setup with ECF | Compiles with simple_yaml, simple_cli |
| T1.2 | LINT_CLI skeleton | Parses file arguments, --help, --version |
| T1.3 | LINT_ENGINE class | Loads file, calls rules, collects results |
| T1.4 | LINT_CONTEXT class | Provides file content and parsed YAML to rules |
| T1.5 | LINT_RESULT class | Stores violations, provides queries |
| T1.6 | LINT_RULE base class | Defines rule interface with DBC contracts |
| T1.7 | RULE_VALID_YAML | Checks YAML syntax |
| T1.8 | RULE_INDENT | Checks consistent indentation |
| T1.9 | RULE_NO_DUPLICATE_KEYS | Detects duplicate mapping keys |
| T1.10 | RULE_LINE_LENGTH | Enforces maximum line length |
| T1.11 | RULE_TRAILING_SPACES | Detects trailing whitespace |
| T1.12 | Text output formatter | Colored text with line:col format |
| T1.13 | Unit tests | 90% coverage of core classes |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| Valid YAML | Well-formed file | No violations |
| Invalid YAML | Syntax error | Parse error violation |
| Bad indent | Mixed 2/4 spaces | Indent violations |
| Duplicate keys | `key: 1` twice | Duplicate key violation |
| Long line | 200 char line | Line length violation |
| Trailing space | "value   \n" | Trailing space violation |
| Multiple files | file1.yml file2.yml | Both files linted |
| Exit code | File with errors | Exit code 1 |

---

## Phase 2: Full Implementation

### Objective

Add comprehensive rule set, rule configuration, JSON Schema validation, auto-fix capability, and multiple output formats. This phase delivers the professional feature set.

### Deliverables

1. **RULE_REGISTRY** - Rule catalog and management
2. **RULE_CONFIG** - Configuration parsing (.yamllint.yml)
3. **SCHEMA_VALIDATOR** - JSON Schema validation
4. **FIX_ENGINE** - Auto-fix implementation
5. **Additional rules:** 20+ built-in rules
6. **Output formats:** JSON, checkstyle, SARIF
7. **CMD_RULES** - Rule management subcommand

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T2.1 | RULE_REGISTRY class | Register, lookup, list rules |
| T2.2 | RULE_CONFIG class | Parse .yamllint.yml config |
| T2.3 | Config inheritance | extends: recommended works |
| T2.4 | SCHEMA_VALIDATOR class | Validate against JSON Schema |
| T2.5 | Built-in schemas | kubernetes, docker-compose |
| T2.6 | 15+ additional rules | See rule list below |
| T2.7 | FIX_ENGINE class | Apply safe fixes |
| T2.8 | LINT_OUTPUT JSON | JSON output format |
| T2.9 | LINT_OUTPUT checkstyle | Checkstyle XML format |
| T2.10 | CMD_RULES list | List all available rules |
| T2.11 | CMD_RULES show | Show rule details |
| T2.12 | Ignore patterns | Support gitignore-style patterns |
| T2.13 | Integration tests | End-to-end workflow tests |

### Additional Rules for Phase 2

| Rule | Category | Description |
|------|----------|-------------|
| no-tabs | formatting | No tab characters |
| newline-at-eof | formatting | File ends with newline |
| key-ordering | formatting | Alphabetical key order |
| quote-style | formatting | Consistent quote usage |
| no-empty-values | structure | No empty string values |
| required-keys | structure | Required keys present |
| max-depth | structure | Maximum nesting depth |
| no-hardcoded-secrets | best-practice | Detect password patterns |
| lowercase-keys | best-practice | Lowercase key names |
| no-anchor-alias | best-practice | No anchors/aliases |
| k8s-valid-kind | domain | Valid K8s resource kinds |
| k8s-required-labels | domain | Required K8s labels |
| docker-service-name | domain | Valid Compose service names |
| github-actions-valid | domain | Valid GitHub Actions |
| no-boolean-strings | best-practice | "true" should be true |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| Load config | .yamllint.yml | Config applied to linting |
| Extends preset | extends: strict | All strict rules enabled |
| Schema validation | K8s deployment | Schema violations reported |
| Auto-fix indent | 4-space indent | Fixed to 2-space |
| JSON output | --format json | Valid JSON array |
| Rules list | rules list | All rules with descriptions |
| Ignore pattern | vendor/** ignored | Files not linted |

---

## Phase 3: Production Polish

### Objective

Add CI/CD-specific output formats, performance optimization, comprehensive documentation, and production hardening.

### Deliverables

1. **CI output formats:** github-actions, gitlab-ci, azure-devops
2. **SARIF output** for security scanning integration
3. **Performance optimization** for large codebases
4. **Parallel processing** for multiple files
5. **Complete documentation**
6. **Pre-built rule presets**

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T3.1 | GitHub Actions format | Annotations in workflow |
| T3.2 | GitLab CI format | Code quality report |
| T3.3 | SARIF format | Security scanner compatible |
| T3.4 | Parallel file processing | Lint files concurrently |
| T3.5 | Caching layer | Cache parsed YAML for repeat runs |
| T3.6 | Preset: recommended | Balanced rule set |
| T3.7 | Preset: strict | All rules, high severity |
| T3.8 | Preset: minimal | Syntax only |
| T3.9 | Preset: kubernetes | K8s-specific rules |
| T3.10 | README.md | Complete user documentation |
| T3.11 | Rule documentation | Each rule fully documented |
| T3.12 | Performance benchmarks | Sub-50ms per file |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| GitHub format | --format github-actions | ::error annotations |
| GitLab format | --format gitlab-ci | GL-CODE-QUALITY report |
| SARIF format | --format sarif | Valid SARIF JSON |
| 1000 files | Large codebase | < 30 seconds total |
| Preset load | extends: kubernetes | K8s rules enabled |

---

## ECF Target Structure

```xml
<!-- Library target (reusable) -->
<target name="yaml_lint">
    <root all_classes="true"/>
    <cluster name="src" location=".\src\" recursive="true"/>
    <cluster name="rules" location=".\src\rules\" recursive="true"/>
    <library name="simple_yaml" location="$SIMPLE_EIFFEL\simple_yaml\simple_yaml.ecf"/>
    <library name="simple_json" location="$SIMPLE_EIFFEL\simple_json\simple_json.ecf"/>
    <library name="simple_cli" location="$SIMPLE_EIFFEL\simple_cli\simple_cli.ecf"/>
    <library name="simple_file" location="$SIMPLE_EIFFEL\simple_file\simple_file.ecf"/>
    <library name="simple_regex" location="$SIMPLE_EIFFEL\simple_regex\simple_regex.ecf"/>
    <library name="base" location="$ISE_LIBRARY\library\base\base.ecf"/>
</target>

<!-- CLI executable target -->
<target name="yaml_lint_cli" extends="yaml_lint">
    <root class="LINT_CLI" feature="make"/>
    <setting name="console_application" value="true"/>
</target>

<!-- Test target -->
<target name="yaml_lint_tests" extends="yaml_lint">
    <root class="TEST_APP" feature="make"/>
    <setting name="console_application" value="true"/>
    <library name="simple_testing" location="$SIMPLE_EIFFEL\simple_testing\simple_testing.ecf"/>
    <cluster name="tests" location=".\tests\" recursive="true"/>
</target>
```

## Build Commands

```bash
# Compile CLI (workbench mode for development)
/d/prod/ec.sh -batch -config yaml_lint.ecf -target yaml_lint_cli -c_compile

# Run tests
/d/prod/ec.sh -batch -config yaml_lint.ecf -target yaml_lint_tests -c_compile
./EIFGENs/yaml_lint_tests/W_code/yaml_lint.exe

# Finalized build (production)
/d/prod/ec.sh -batch -config yaml_lint.ecf -target yaml_lint_cli -finalize -c_compile

# Production executable
./EIFGENs/yaml_lint_cli/F_code/yaml-lint.exe
```

## Success Criteria

| Criterion | Measure | Target |
|-----------|---------|--------|
| Compiles | Zero errors, zero warnings | 100% |
| Tests pass | All contract and unit tests | 100% |
| CLI works | All commands functional | Pass |
| Performance | Per-file lint time | < 50ms |
| Rules | Built-in rule count | 30+ |
| Documentation | README + rule docs | Complete |

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Rule complexity | Start with simple rules, add complexity |
| Schema loading performance | Lazy load, cache schemas |
| Regex performance | Compile patterns once, reuse |
| Large file handling | Stream processing option |

## Next Steps After Completion

1. Alpha release to internal projects
2. Gather rule requests from users
3. Add IDE integration (LSP server)
4. Create marketplace for custom rules
5. Build analytics dashboard (Pro feature)
