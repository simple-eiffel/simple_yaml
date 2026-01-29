# YAML Config Manager - Technical Design

## Architecture

### Component Overview

```
+------------------------------------------------------------------+
|                      YAML Config Manager                          |
+------------------------------------------------------------------+
|  CLI Interface Layer                                              |
|    - CONFIG_CLI           : Argument parsing, command routing     |
|    - CONFIG_OUTPUT        : Output formatting (text, json, yaml)  |
|    - CONFIG_HELP          : Help system and documentation         |
+------------------------------------------------------------------+
|  Business Logic Layer                                             |
|    - CONFIG_ENGINE        : Core config operations                |
|    - CONFIG_MERGER        : Multi-file merge logic                |
|    - CONFIG_VALIDATOR     : Schema and rule validation            |
|    - CONFIG_DIFFER        : Configuration comparison              |
|    - ENV_MANAGER          : Environment hierarchy management      |
+------------------------------------------------------------------+
|  Security Layer                                                   |
|    - SECRETS_HANDLER      : Encryption/decryption operations      |
|    - SECRETS_SCANNER      : Detect secrets in configs             |
|    - AUDIT_LOGGER         : Track all config changes              |
+------------------------------------------------------------------+
|  Persistence Layer                                                |
|    - CONFIG_STORE         : Local config file management          |
|    - CONFIG_HISTORY       : Version history tracking              |
|    - CONFIG_LOCK          : Concurrent access management          |
+------------------------------------------------------------------+
|  Integration Layer                                                |
|    - simple_yaml          : YAML parsing/generation               |
|    - simple_json          : JSON import/export                    |
|    - simple_file          : File system operations                |
|    - simple_encryption    : Secrets encryption                    |
|    - simple_diff          : Configuration differencing            |
|    - simple_cli           : CLI framework                         |
|    - simple_template      : Variable substitution                 |
+------------------------------------------------------------------+
```

### Class Design

| Class | Responsibility | Key Features |
|-------|----------------|--------------|
| CONFIG_CLI | Command-line interface | parse_args, execute, format_output, show_help |
| CONFIG_ENGINE | Core business logic | load, save, get, set, merge, validate |
| CONFIG_MERGER | Multi-file merge | deep_merge, conflict_resolve, preserve_comments |
| CONFIG_VALIDATOR | Validation engine | validate_schema, validate_rules, report_errors |
| CONFIG_DIFFER | Configuration diff | compute_diff, format_diff, highlight_changes |
| ENV_MANAGER | Environment handling | create_env, set_inheritance, resolve_hierarchy |
| SECRETS_HANDLER | Encryption ops | encrypt_value, decrypt_value, rotate_keys |
| SECRETS_SCANNER | Secret detection | scan_for_secrets, mask_secrets, audit_secrets |
| AUDIT_LOGGER | Change tracking | log_change, query_history, export_audit |
| CONFIG_STORE | File persistence | load_file, save_file, backup_file |
| CONFIG_HISTORY | Version control | save_version, rollback, list_versions |
| CONFIG_LOCK | Concurrency | acquire_lock, release_lock, check_lock |
| CONFIG_OUTPUT | Output formatting | to_text, to_json, to_yaml, to_table |

### Command Structure

```bash
yaml-config <command> [subcommand] [options] [arguments]

Commands:
  get <path>              Get value at dot-path
  set <path> <value>      Set value at dot-path
  delete <path>           Delete key at path
  merge <file1> <file2>   Merge configuration files
  diff <file1> <file2>    Compare configuration files
  validate <file>         Validate configuration against schema

  env list                List all environments
  env create <name>       Create new environment
  env delete <name>       Delete environment
  env inherit <child> <parent>  Set inheritance
  env switch <name>       Switch active environment
  env show <name>         Show environment config

  secrets encrypt <file>  Encrypt secrets in file
  secrets decrypt <file>  Decrypt secrets in file
  secrets rotate          Rotate encryption keys
  secrets audit           Audit secret usage

  history list            List config versions
  history show <version>  Show specific version
  history rollback <ver>  Rollback to version

  deploy --env <name>     Deploy configuration
  init                    Initialize config project

Global Options:
  --config FILE           Path to yaml-config settings
  --env ENV               Target environment (default: development)
  --output FORMAT         Output format: text|json|yaml|table (default: text)
  --verbose               Verbose output
  --quiet                 Suppress non-essential output
  --dry-run               Show what would happen without doing it
  --help                  Show help for command
  --version               Show version information
```

### Data Flow

```
                      +------------------+
                      |   User Command   |
                      +--------+---------+
                               |
                               v
                      +--------+---------+
                      |   CONFIG_CLI     |
                      |   parse & route  |
                      +--------+---------+
                               |
              +----------------+----------------+
              |                |                |
              v                v                v
     +--------+------+ +-------+-------+ +------+--------+
     | CONFIG_ENGINE | | ENV_MANAGER   | | SECRETS_HANDLER|
     | load/get/set  | | resolve env   | | encrypt/decrypt|
     +--------+------+ +-------+-------+ +------+--------+
              |                |                |
              +----------------+----------------+
                               |
                               v
                      +--------+---------+
                      |  CONFIG_STORE    |
                      |  file I/O        |
                      +--------+---------+
                               |
                               v
                      +--------+---------+
                      | CONFIG_HISTORY   |
                      | version tracking |
                      +--------+---------+
                               |
                               v
                      +--------+---------+
                      | CONFIG_OUTPUT    |
                      | format result    |
                      +--------+---------+
                               |
                               v
                      +------------------+
                      |   stdout/file    |
                      +------------------+
```

### Configuration Schema

**Project Configuration (yaml-config.yml):**
```yaml
yaml-config:
  version: "1.0"
  project:
    name: "my-application"
    root: "./configs"

  environments:
    base:
      file: "base.yml"
    development:
      inherits: base
      file: "development.yml"
    staging:
      inherits: development
      file: "staging.yml"
    production:
      inherits: base
      file: "production.yml"

  secrets:
    encryption: "aes-256-gcm"
    key_file: ".secrets-key"
    patterns:
      - "password"
      - "secret"
      - "api_key"
      - "token"

  validation:
    schema: "schema.yml"
    rules:
      - required: ["database.host", "database.port"]
      - type: "database.port": integer
      - range: "database.pool_size": [1, 100]

  output:
    default_format: "yaml"
    preserve_comments: true
    sort_keys: false

  history:
    enabled: true
    max_versions: 50
    location: ".config-history"
```

### Error Handling

| Error Type | Handling | User Message |
|------------|----------|--------------|
| FileNotFound | Return error, suggest init | "Config file not found: {path}. Run 'yaml-config init' to create." |
| ParseError | Return parse errors with line numbers | "YAML parse error at line {n}: {message}" |
| ValidationError | Return all validation failures | "Validation failed: {count} errors found. See --verbose for details." |
| MergeConflict | Prompt for resolution or use strategy | "Merge conflict at {path}. Use --strategy to resolve." |
| EncryptionError | Return error, don't expose internals | "Encryption failed. Check key file permissions." |
| PermissionDenied | Return error with suggestion | "Permission denied: {path}. Check file permissions." |
| LockConflict | Return error with lock holder info | "Config locked by {user} since {time}. Use --force to override." |
| SchemaViolation | Return detailed schema errors | "Schema violation at {path}: expected {type}, got {actual}" |

## GUI/TUI Future Path

**CLI foundation enables:**

1. **TUI Mode (simple_tui):**
   - Interactive environment selector
   - Real-time validation feedback
   - Side-by-side diff viewer
   - Secrets management wizard

2. **GUI Application (future):**
   - Visual config editor with syntax highlighting
   - Environment tree navigator
   - Drag-and-drop config promotion
   - Graphical diff viewer
   - Dashboard for config health metrics

3. **Shared Components:**
   - CONFIG_ENGINE, CONFIG_MERGER, CONFIG_VALIDATOR all GUI-agnostic
   - CONFIG_OUTPUT already supports multiple formats
   - All business logic testable without UI

## Security Considerations

1. **Secrets Never in Logs:** Audit logger masks secret values
2. **Memory Safety:** Void-safe Eiffel prevents null pointer issues
3. **Key Management:** Keys stored separately from encrypted data
4. **Least Privilege:** Operations require explicit environment targeting
5. **Audit Trail:** All changes logged with timestamp, user, and diff
