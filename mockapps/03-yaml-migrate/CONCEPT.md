# YAML Migrate (yaml-migrate)

## Executive Summary

YAML Migrate is a comprehensive format conversion and configuration migration CLI tool. It enables seamless transformation between YAML, JSON, TOML, and environment files (.env), with intelligent mapping of data structures and optional schema migration support.

The tool addresses the fragmentation in configuration formats across modern development ecosystems. Teams adopting Kubernetes need to convert existing JSON configs to YAML. Organizations modernizing legacy systems need to migrate INI files to YAML. DevOps engineers need to synchronize environment variables with YAML configuration. YAML Migrate provides a single, reliable tool for all these conversions.

Built with Design by Contract principles, every conversion preserves data integrity with verifiable pre- and post-conditions, ensuring that migrations are safe and reversible.

## Problem Statement

**The problem:** Modern software stacks use multiple configuration formats, creating challenges:
- JSON configs need conversion to YAML for Kubernetes
- TOML configs (Rust, Python) need interop with YAML-based tools
- Environment files need synchronization with structured configs
- Legacy INI/properties files need modernization
- Manual conversion is error-prone and tedious
- Format-specific tools don't interoperate

**Current solutions:**
- Online converters (privacy concerns, no batch processing)
- Language-specific libraries (require coding)
- Shell scripts with jq/yq (fragile, limited)
- Manual conversion (slow, error-prone)

**Our approach:**
- Single binary for all common format conversions
- Bidirectional conversion with round-trip fidelity
- Batch processing for migration projects
- Schema-guided migration for complex transformations
- Diff mode to verify conversion accuracy
- Dry-run capability for safe migrations

## Target Users

| User Type | Description | Key Needs |
|-----------|-------------|-----------|
| Primary: DevOps Engineer | Migrating to Kubernetes/YAML | Bulk JSON->YAML conversion, accuracy |
| Primary: Platform Engineer | Standardizing config formats | Batch migration, schema mapping |
| Secondary: Backend Developer | Working across format boundaries | Quick ad-hoc conversions |
| Secondary: Data Engineer | ETL configuration migration | Structured transformation rules |

## Value Proposition

**For** DevOps and platform engineers
**Who** need to migrate between configuration formats
**This app** provides comprehensive format conversion with schema mapping
**Unlike** online converters or format-specific tools
**We** offer offline batch processing, round-trip fidelity, and migration verification built on the reliable simple_* ecosystem.

## Revenue Model

| Model | Description | Price Point |
|-------|-------------|-------------|
| Community Edition | Basic conversions (YAML, JSON) | Free / Open Source |
| Pro License | All formats, batch processing, schema mapping | $149 one-time |
| Enterprise License | Custom format support, priority support | $499 one-time |

## Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Conversion accuracy | 100% data preservation | Round-trip tests |
| Format coverage | 5+ formats | Supported format count |
| Conversion speed | 1000 files/minute | Benchmark tests |
| User satisfaction | < 5 min first conversion | Time to first success |

## Core Features

### Basic Conversion
```bash
yaml-migrate json2yaml config.json           # JSON to YAML
yaml-migrate yaml2json config.yml            # YAML to JSON
yaml-migrate toml2yaml pyproject.toml        # TOML to YAML
yaml-migrate yaml2toml config.yml            # YAML to TOML
yaml-migrate env2yaml .env                   # Env file to YAML
yaml-migrate yaml2env config.yml             # YAML to env file
```

### Batch Processing
```bash
yaml-migrate batch json2yaml src/*.json      # Convert all JSON files
yaml-migrate batch json2yaml src/ -o dest/   # Convert directory
yaml-migrate batch json2yaml --recursive .   # Recursive conversion
yaml-migrate batch --mapping mapping.yml     # Use mapping file
```

### Schema Migration
```bash
yaml-migrate migrate config.json --schema migration.yml
yaml-migrate migrate --from v1 --to v2 config.yml
yaml-migrate generate-schema config.yml      # Generate migration schema
```

### Verification
```bash
yaml-migrate verify config.yml converted.json  # Verify equivalence
yaml-migrate diff config.yml converted.json    # Show differences
yaml-migrate roundtrip config.yml              # Test round-trip
yaml-migrate --dry-run json2yaml config.json   # Preview without writing
```

### Format Detection
```bash
yaml-migrate detect config.txt                 # Detect format
yaml-migrate convert config.txt --to yaml      # Auto-detect and convert
yaml-migrate info config.yml                   # Show structure info
```

## Supported Formats

| Format | Extension | Read | Write | Notes |
|--------|-----------|------|-------|-------|
| YAML | .yml, .yaml | Yes | Yes | YAML 1.2, block & flow |
| JSON | .json | Yes | Yes | Compact & pretty |
| TOML | .toml | Yes | Yes | TOML 1.0 |
| ENV | .env | Yes | Yes | Docker-style |
| INI | .ini, .cfg | Yes | Limited | Basic key-value |
| Properties | .properties | Yes | Yes | Java properties |

## Conversion Rules

### Type Mapping

| Source (JSON) | Target (YAML) |
|---------------|---------------|
| `{}` object | mapping |
| `[]` array | sequence |
| `"string"` | string (unquoted if safe) |
| `123` | integer |
| `1.5` | float |
| `true/false` | boolean |
| `null` | null |

### Special Handling

- **Comments:** Preserved where format supports
- **Key ordering:** Preserved (not alphabetized)
- **Multiline strings:** Converted to YAML block scalars
- **Dates:** Preserved as strings unless schema specifies
- **Anchors/Aliases:** Expanded in JSON, preserved in YAML

## Competitive Advantages

1. **Multi-Format:** Single tool for all common formats.

2. **Batch Processing:** Handle migration projects, not just single files.

3. **Round-Trip Fidelity:** Verify conversions preserve all data.

4. **Schema Migration:** Transform structure, not just format.

5. **Offline First:** No data sent to external services.

6. **Contract-Driven:** Every conversion verified with DBC.
