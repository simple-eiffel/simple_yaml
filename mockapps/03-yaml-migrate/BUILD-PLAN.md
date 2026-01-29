# YAML Migrate - Build Plan

## Phase Overview

| Phase | Deliverable | Effort | Dependencies |
|-------|-------------|--------|--------------|
| Phase 1 | MVP CLI (YAML/JSON conversion) | 4 days | simple_yaml, simple_json, simple_cli |
| Phase 2 | Full CLI (all formats, batch) | 6 days | Phase 1 + simple_toml, simple_env |
| Phase 3 | Polish (schema migration, verification) | 4 days | Phase 2 + simple_diff |

---

## Phase 1: MVP

### Objective

Create a functional CLI that can convert between YAML and JSON formats with round-trip fidelity. This MVP demonstrates the common data model approach and proves the architecture.

### Deliverables

1. **MIGRATE_CLI** - Main CLI entry point
2. **CONVERT_ENGINE** - Core conversion orchestration
3. **CONFIG_NODE hierarchy** - Common data model
4. **YAML_HANDLER** - YAML format support
5. **JSON_HANDLER** - JSON format support
6. **FORMAT_DETECTOR** - Auto-detect input format
7. **Commands:** json2yaml, yaml2json, convert, detect

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T1.1 | Project setup with ECF | Compiles with simple_yaml, simple_json |
| T1.2 | CONFIG_NODE base class | Abstract node interface defined |
| T1.3 | CONFIG_MAPPING class | Key-value storage with ordering |
| T1.4 | CONFIG_SEQUENCE class | Ordered list storage |
| T1.5 | CONFIG_SCALAR class | All scalar types supported |
| T1.6 | YAML_HANDLER read | Parse YAML to CONFIG_NODE |
| T1.7 | YAML_HANDLER write | Convert CONFIG_NODE to YAML |
| T1.8 | JSON_HANDLER read | Parse JSON to CONFIG_NODE |
| T1.9 | JSON_HANDLER write | Convert CONFIG_NODE to JSON |
| T1.10 | FORMAT_DETECTOR | Detect YAML vs JSON by content |
| T1.11 | CONVERT_ENGINE | Orchestrate format handlers |
| T1.12 | MIGRATE_CLI skeleton | Basic command parsing |
| T1.13 | Unit tests | 90% coverage of handlers |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| JSON to YAML | `{"key": "value"}` | `key: value` |
| YAML to JSON | `key: value` | `{"key": "value"}` |
| Nested conversion | Deep JSON object | Equivalent YAML |
| Array conversion | JSON array | YAML sequence |
| Type preservation | integers, bools, nulls | Same types |
| Round-trip JSON | config.json -> yaml -> json | Equivalent |
| Round-trip YAML | config.yml -> json -> yaml | Equivalent |
| Auto-detect JSON | file without extension | Correctly detected |
| Auto-detect YAML | file without extension | Correctly detected |

---

## Phase 2: Full Implementation

### Objective

Add support for all target formats (TOML, ENV, INI, Properties), implement batch processing, and add output options.

### Deliverables

1. **TOML_HANDLER** - TOML format support
2. **ENV_HANDLER** - Env file support with flatten/unflatten
3. **INI_HANDLER** - INI file support
4. **PROPERTIES_HANDLER** - Java properties support
5. **BATCH_PROCESSOR** - Multi-file processing
6. **FILE_MAPPER** - Path mapping for batch
7. **All conversion commands**

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T2.1 | TOML_HANDLER read | Parse TOML to CONFIG_NODE |
| T2.2 | TOML_HANDLER write | Convert CONFIG_NODE to TOML |
| T2.3 | ENV_HANDLER read | Parse .env to CONFIG_NODE |
| T2.4 | ENV_HANDLER write | Convert CONFIG_NODE to .env |
| T2.5 | ENV unflatten | DATABASE_HOST -> database.host |
| T2.6 | INI_HANDLER read | Parse INI to CONFIG_NODE |
| T2.7 | INI_HANDLER write | Convert CONFIG_NODE to INI |
| T2.8 | PROPERTIES_HANDLER | Java properties support |
| T2.9 | BATCH_PROCESSOR | Process multiple files |
| T2.10 | FILE_MAPPER | Map input to output paths |
| T2.11 | All toml2* commands | TOML source commands |
| T2.12 | All env2* commands | ENV source commands |
| T2.13 | --pretty / --compact | Output formatting options |
| T2.14 | --preserve-order | Key ordering option |
| T2.15 | Integration tests | End-to-end conversions |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| TOML to YAML | pyproject.toml | Valid YAML |
| YAML to TOML | config.yml | Valid TOML |
| ENV to YAML | .env | Structured YAML |
| YAML to ENV | config.yml | Flat .env |
| ENV unflatten | DATABASE_HOST=x | database.host: x |
| INI to YAML | config.ini | Valid YAML |
| Batch convert | src/*.json | dest/*.yml |
| Recursive batch | src/**/*.json | All converted |
| Pretty output | --pretty | Indented output |
| Compact output | --compact | Minimal whitespace |

---

## Phase 3: Production Polish

### Objective

Add schema migration support, verification capabilities, and production hardening. Complete documentation and optimize performance.

### Deliverables

1. **SCHEMA_MIGRATOR** - Apply schema transformations
2. **MIGRATION_RULE** - Rule definitions
3. **VERIFY_ENGINE** - Equivalence checking
4. **DIFF_ENGINE** - Structural diff
5. **ROUNDTRIP_TESTER** - Round-trip verification
6. **Complete documentation**
7. **Performance optimization**

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T3.1 | SCHEMA_MIGRATOR class | Load and apply migration rules |
| T3.2 | MIGRATION_RULE types | rename, move, transform, add, remove |
| T3.3 | Migration spec parser | Parse migration.yml |
| T3.4 | VERIFY_ENGINE | Compare two configs |
| T3.5 | DIFF_ENGINE | Show differences |
| T3.6 | verify command | yaml-migrate verify a b |
| T3.7 | diff command | yaml-migrate diff a b |
| T3.8 | roundtrip command | yaml-migrate roundtrip file |
| T3.9 | --dry-run | Preview without writing |
| T3.10 | Parallel batch | Concurrent file processing |
| T3.11 | README.md | Complete documentation |
| T3.12 | Performance benchmarks | 1000+ files/minute |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| Rename rule | {old: x} + rename rule | {new: x} |
| Move rule | flat key + move rule | nested key |
| Transform rule | seconds + *1000 | milliseconds |
| Add rule | missing key + add rule | key with default |
| Remove rule | deprecated + remove rule | key removed |
| Verify same | same content, diff format | Equivalent |
| Verify different | different content | Not equivalent |
| Diff output | two different configs | Differences listed |
| Round-trip | any config | Original = converted back |
| Dry-run | --dry-run | Preview shown, no writes |

---

## ECF Target Structure

```xml
<!-- Library target (reusable) -->
<target name="yaml_migrate">
    <root all_classes="true"/>
    <cluster name="src" location=".\src\" recursive="true"/>
    <cluster name="handlers" location=".\src\handlers\" recursive="true"/>
    <library name="simple_yaml" location="$SIMPLE_EIFFEL\simple_yaml\simple_yaml.ecf"/>
    <library name="simple_json" location="$SIMPLE_EIFFEL\simple_json\simple_json.ecf"/>
    <library name="simple_toml" location="$SIMPLE_EIFFEL\simple_toml\simple_toml.ecf"/>
    <library name="simple_env" location="$SIMPLE_EIFFEL\simple_env\simple_env.ecf"/>
    <library name="simple_file" location="$SIMPLE_EIFFEL\simple_file\simple_file.ecf"/>
    <library name="simple_cli" location="$SIMPLE_EIFFEL\simple_cli\simple_cli.ecf"/>
    <library name="simple_diff" location="$SIMPLE_EIFFEL\simple_diff\simple_diff.ecf"/>
    <library name="base" location="$ISE_LIBRARY\library\base\base.ecf"/>
</target>

<!-- CLI executable target -->
<target name="yaml_migrate_cli" extends="yaml_migrate">
    <root class="MIGRATE_CLI" feature="make"/>
    <setting name="console_application" value="true"/>
</target>

<!-- Test target -->
<target name="yaml_migrate_tests" extends="yaml_migrate">
    <root class="TEST_APP" feature="make"/>
    <setting name="console_application" value="true"/>
    <library name="simple_testing" location="$SIMPLE_EIFFEL\simple_testing\simple_testing.ecf"/>
    <cluster name="tests" location=".\tests\" recursive="true"/>
</target>
```

## Build Commands

```bash
# Compile CLI (workbench mode for development)
/d/prod/ec.sh -batch -config yaml_migrate.ecf -target yaml_migrate_cli -c_compile

# Run tests
/d/prod/ec.sh -batch -config yaml_migrate.ecf -target yaml_migrate_tests -c_compile
./EIFGENs/yaml_migrate_tests/W_code/yaml_migrate.exe

# Finalized build (production)
/d/prod/ec.sh -batch -config yaml_migrate.ecf -target yaml_migrate_cli -finalize -c_compile

# Production executable
./EIFGENs/yaml_migrate_cli/F_code/yaml-migrate.exe
```

## Success Criteria

| Criterion | Measure | Target |
|-----------|---------|--------|
| Compiles | Zero errors, zero warnings | 100% |
| Tests pass | All contract and unit tests | 100% |
| CLI works | All commands functional | Pass |
| Round-trip | All formats preserve data | 100% |
| Performance | Files per minute | 1000+ |
| Formats | Supported format count | 6+ |
| Documentation | README complete | Yes |

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| simple_toml not ready | Defer TOML support to Phase 2.5 |
| Format edge cases | Extensive test suite with real-world files |
| Large file handling | Streaming implementation |
| Type coercion issues | Strict type mapping with documentation |

## Next Steps After Completion

1. Release as standalone tool
2. Add to simple-eiffel CLI toolkit
3. Create VS Code extension
4. Add more exotic formats (XML, HCL)
5. Cloud sync option for enterprise
