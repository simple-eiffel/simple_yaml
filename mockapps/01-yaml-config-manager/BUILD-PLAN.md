# YAML Config Manager - Build Plan

## Phase Overview

| Phase | Deliverable | Effort | Dependencies |
|-------|-------------|--------|--------------|
| Phase 1 | MVP CLI (get/set/validate) | 5 days | simple_yaml, simple_cli, simple_file |
| Phase 2 | Full CLI (merge/diff/secrets) | 7 days | Phase 1 + simple_diff, simple_encryption |
| Phase 3 | Polish (history/deploy/enterprise) | 5 days | Phase 2 + simple_logger |

---

## Phase 1: MVP

### Objective

Create a functional CLI that can load YAML configs, get/set values using dot-path notation, and validate configurations. This MVP demonstrates core value and proves the architecture.

### Deliverables

1. **CONFIG_CLI** - Main CLI entry point with argument parsing
2. **CONFIG_ENGINE** - Core load/save/get/set operations
3. **CONFIG_VALIDATOR** - Basic YAML validation
4. **CONFIG_OUTPUT** - Text and YAML output formatting
5. **Basic commands:** `get`, `set`, `delete`, `validate`, `init`

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T1.1 | Project setup with ECF | Compiles with simple_yaml, simple_cli |
| T1.2 | CONFIG_CLI skeleton | Parses `--help`, `--version` |
| T1.3 | CONFIG_ENGINE.load | Loads YAML file, returns YAML_VALUE |
| T1.4 | CONFIG_ENGINE.get | Gets value at dot-path |
| T1.5 | CONFIG_ENGINE.set | Sets value at dot-path, saves file |
| T1.6 | CONFIG_ENGINE.delete | Removes key at path |
| T1.7 | CMD_GET implementation | `yaml-config get database.host` works |
| T1.8 | CMD_SET implementation | `yaml-config set database.port 5432` works |
| T1.9 | CMD_VALIDATE implementation | Validates YAML syntax |
| T1.10 | CMD_INIT implementation | Creates yaml-config.yml template |
| T1.11 | Output formatting | Text and YAML output modes |
| T1.12 | Unit tests | 90% coverage of CONFIG_ENGINE |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| Get existing string | `get database.host` on valid config | "localhost" |
| Get existing integer | `get database.port` on valid config | 5432 |
| Get nested path | `get server.ssl.enabled` | true/false |
| Get missing path | `get nonexistent.key` | Error: key not found |
| Set new value | `set app.name "MyApp"` | Config updated, success message |
| Set nested value | `set server.timeout 30` | Creates nested structure if needed |
| Delete key | `delete cache.enabled` | Key removed, success message |
| Validate valid YAML | `validate good.yml` | "Valid YAML" |
| Validate invalid YAML | `validate bad.yml` | Error with line number |
| Init new project | `init` | Creates yaml-config.yml |

---

## Phase 2: Full Implementation

### Objective

Add environment management, configuration merging, differencing, and encrypted secrets support. This phase delivers the full feature set for DevOps workflows.

### Deliverables

1. **ENV_MANAGER** - Environment hierarchy and switching
2. **CONFIG_MERGER** - Deep merge with conflict resolution
3. **CONFIG_DIFFER** - Configuration comparison
4. **SECRETS_HANDLER** - Encryption/decryption
5. **SECRETS_SCANNER** - Detect and mask secrets
6. **Commands:** `env`, `merge`, `diff`, `secrets`

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T2.1 | ENV_MANAGER class | Create, list, switch environments |
| T2.2 | Environment inheritance | Child inherits from parent |
| T2.3 | CMD_ENV implementation | All env subcommands work |
| T2.4 | CONFIG_MERGER class | Deep merge two YAML trees |
| T2.5 | Merge conflict strategies | last-wins, first-wins, fail |
| T2.6 | CMD_MERGE implementation | `yaml-config merge a.yml b.yml` |
| T2.7 | CONFIG_DIFFER class | Compute diff between configs |
| T2.8 | Diff output formats | text, unified, json |
| T2.9 | CMD_DIFF implementation | `yaml-config diff dev.yml prod.yml` |
| T2.10 | SECRETS_HANDLER class | AES-256 encrypt/decrypt |
| T2.11 | SECRETS_SCANNER class | Detect patterns like "password" |
| T2.12 | CMD_SECRETS implementation | encrypt, decrypt, audit |
| T2.13 | Integration tests | End-to-end workflow tests |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| Create environment | `env create staging` | Environment created |
| Set inheritance | `env inherit staging development` | Inheritance configured |
| Switch environment | `env switch production` | Active env changed |
| List environments | `env list` | All environments shown |
| Merge configs | `merge base.yml override.yml` | Merged output |
| Merge conflict | `merge a.yml b.yml --strategy=fail` | Conflict reported |
| Diff configs | `diff dev.yml prod.yml` | Differences shown |
| Diff identical | `diff same.yml same.yml` | "No differences" |
| Encrypt secrets | `secrets encrypt config.yml` | Secrets encrypted in place |
| Decrypt secrets | `secrets decrypt config.yml` | Secrets decrypted |
| Audit secrets | `secrets audit` | List of secret locations |

---

## Phase 3: Production Polish

### Objective

Add version history, deployment integration, audit logging, and enterprise features. Polish error handling, documentation, and performance.

### Deliverables

1. **CONFIG_HISTORY** - Version tracking and rollback
2. **AUDIT_LOGGER** - Change audit trail
3. **CMD_HISTORY** - History commands
4. **CMD_DEPLOY** - Deployment workflow
5. **Error handling hardening**
6. **Performance optimization**
7. **Complete documentation**

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T3.1 | CONFIG_HISTORY class | Save, list, rollback versions |
| T3.2 | CMD_HISTORY implementation | history list/show/rollback |
| T3.3 | AUDIT_LOGGER class | Log all config changes |
| T3.4 | Audit report generation | Export audit trail |
| T3.5 | CMD_DEPLOY implementation | Deploy with validation |
| T3.6 | Error message review | All errors user-friendly |
| T3.7 | Performance profiling | Sub-second operations |
| T3.8 | README.md | Complete user documentation |
| T3.9 | Man page | Unix man page |
| T3.10 | Release build | Finalized binary |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| List history | `history list` | Version list with timestamps |
| Show version | `history show v3` | Config at that version |
| Rollback | `history rollback v2` | Config restored |
| Deploy | `deploy --env production` | Validation + deployment |
| Deploy dry-run | `deploy --env prod --dry-run` | Shows what would happen |
| Audit export | `secrets audit --export json` | JSON audit report |

---

## ECF Target Structure

```xml
<!-- Library target (reusable) -->
<target name="yaml_config">
    <root all_classes="true"/>
    <cluster name="src" location=".\src\" recursive="true"/>
    <library name="simple_yaml" location="$SIMPLE_EIFFEL\simple_yaml\simple_yaml.ecf"/>
    <library name="simple_json" location="$SIMPLE_EIFFEL\simple_json\simple_json.ecf"/>
    <library name="simple_cli" location="$SIMPLE_EIFFEL\simple_cli\simple_cli.ecf"/>
    <library name="simple_file" location="$SIMPLE_EIFFEL\simple_file\simple_file.ecf"/>
    <library name="simple_diff" location="$SIMPLE_EIFFEL\simple_diff\simple_diff.ecf"/>
    <library name="simple_encryption" location="$SIMPLE_EIFFEL\simple_encryption\simple_encryption.ecf"/>
    <library name="base" location="$ISE_LIBRARY\library\base\base.ecf"/>
</target>

<!-- CLI executable target -->
<target name="yaml_config_cli" extends="yaml_config">
    <root class="CONFIG_CLI" feature="make"/>
    <setting name="console_application" value="true"/>
</target>

<!-- Test target -->
<target name="yaml_config_tests" extends="yaml_config">
    <root class="TEST_APP" feature="make"/>
    <setting name="console_application" value="true"/>
    <library name="simple_testing" location="$SIMPLE_EIFFEL\simple_testing\simple_testing.ecf"/>
    <cluster name="tests" location=".\tests\" recursive="true"/>
</target>
```

## Build Commands

```bash
# Compile CLI (workbench mode for development)
/d/prod/ec.sh -batch -config yaml_config.ecf -target yaml_config_cli -c_compile

# Run tests
/d/prod/ec.sh -batch -config yaml_config.ecf -target yaml_config_tests -c_compile
./EIFGENs/yaml_config_tests/W_code/yaml_config.exe

# Finalized build (production)
/d/prod/ec.sh -batch -config yaml_config.ecf -target yaml_config_cli -finalize -c_compile

# Production executable
./EIFGENs/yaml_config_cli/F_code/yaml-config.exe
```

## Success Criteria

| Criterion | Measure | Target |
|-----------|---------|--------|
| Compiles | Zero errors, zero warnings | 100% |
| Tests pass | All contract and unit tests | 100% |
| CLI works | All commands functional | Pass |
| Performance | Config operations | < 100ms |
| Documentation | README complete | Yes |
| Code quality | No DBC violations | Pass |

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| simple_cli not mature enough | Fall back to manual arg parsing |
| simple_encryption integration issues | Use ISE_CRYPTO as backup |
| Performance with large configs | Lazy loading, caching |
| Complex merge conflicts | Default to fail-safe strategy |

## Next Steps After Completion

1. Beta release to internal users
2. Gather feedback on CLI ergonomics
3. Plan TUI mode using simple_tui
4. Create installer package
5. Publish to simple-eiffel organization
