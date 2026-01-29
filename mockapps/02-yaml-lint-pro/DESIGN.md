# YAML Lint Pro - Technical Design

## Architecture

### Component Overview

```
+------------------------------------------------------------------+
|                        YAML Lint Pro                              |
+------------------------------------------------------------------+
|  CLI Interface Layer                                              |
|    - LINT_CLI             : Argument parsing, file discovery      |
|    - LINT_OUTPUT          : Output formatting (json, xml, text)   |
|    - LINT_REPORTER        : Report generation                     |
+------------------------------------------------------------------+
|  Linting Engine                                                   |
|    - LINT_ENGINE          : Orchestrates linting process          |
|    - LINT_CONTEXT         : File context for rules                |
|    - LINT_RESULT          : Violation collection                  |
+------------------------------------------------------------------+
|  Rule System                                                      |
|    - LINT_RULE            : Base rule interface                   |
|    - RULE_REGISTRY        : Available rules catalog               |
|    - RULE_CONFIG          : Rule configuration                    |
|    - RULE_FACTORY         : Rule instantiation                    |
+------------------------------------------------------------------+
|  Built-in Rules                                                   |
|    - RULE_VALID_YAML      : Syntax validation                     |
|    - RULE_INDENT          : Indentation checking                  |
|    - RULE_NO_DUPLICATES   : Duplicate key detection               |
|    - RULE_LINE_LENGTH     : Line length limits                    |
|    - ... (50+ rules)                                              |
+------------------------------------------------------------------+
|  Schema Validation                                                |
|    - SCHEMA_VALIDATOR     : JSON Schema validation                |
|    - SCHEMA_LOADER        : Load schemas from files/URLs          |
|    - SCHEMA_REGISTRY      : Built-in schema catalog               |
+------------------------------------------------------------------+
|  Auto-Fix System                                                  |
|    - FIX_ENGINE           : Apply fixes to files                  |
|    - FIX_STRATEGY         : Fix implementation per rule           |
+------------------------------------------------------------------+
|  Integration Layer                                                |
|    - simple_yaml          : YAML parsing                          |
|    - simple_json          : JSON Schema support                   |
|    - simple_cli           : CLI framework                         |
|    - simple_file          : File operations                       |
|    - simple_regex         : Pattern matching                      |
|    - simple_validation    : Validation framework                  |
+------------------------------------------------------------------+
```

### Class Design

| Class | Responsibility | Key Features |
|-------|----------------|--------------|
| LINT_CLI | Command-line interface | parse_args, discover_files, execute |
| LINT_ENGINE | Orchestrate linting | lint_file, lint_directory, apply_rules |
| LINT_CONTEXT | Linting context | file_path, content, parsed_yaml, line_map |
| LINT_RESULT | Violation collection | violations, warnings, errors, add_violation |
| LINT_RULE | Base rule class | check, severity, message, fixable |
| RULE_REGISTRY | Rule catalog | register, lookup, list_all, filter_by_category |
| RULE_CONFIG | Rule settings | enabled, severity, options |
| RULE_FACTORY | Rule instantiation | create_rule, configure_rule |
| SCHEMA_VALIDATOR | Schema validation | validate_against_schema, schema_errors |
| SCHEMA_LOADER | Load schemas | load_from_file, load_from_url, load_builtin |
| FIX_ENGINE | Apply fixes | fix_violations, preview_fixes |
| LINT_OUTPUT | Format output | to_json, to_xml, to_text, to_github |
| LINT_REPORTER | Generate reports | summary, detailed, sarif |

### Command Structure

```bash
yaml-lint [options] <files...>

Linting Options:
  -c, --config FILE       Configuration file (default: .yamllint.yml)
  -r, --rules RULES       Comma-separated rules to enable
  -d, --disable RULES     Comma-separated rules to disable
  -s, --schema FILE       JSON Schema to validate against
  --schema-builtin NAME   Use built-in schema (k8s, docker, github-actions)
  --strict                Treat warnings as errors

Output Options:
  -f, --format FORMAT     Output format: text|json|xml|github|gitlab|checkstyle
  -o, --output FILE       Write output to file
  --color                 Force colored output
  --no-color              Disable colored output
  -q, --quiet             Only show errors

Fix Options:
  --fix                   Auto-fix safe violations
  --fix-dry-run           Show what would be fixed
  --fix-unsafe            Include unsafe fixes (may change semantics)

Rule Management:
  rules list              List all available rules
  rules show <rule>       Show rule details and examples
  rules create <name>     Create custom rule template
  rules test <file>       Test custom rule

Other:
  -v, --verbose           Verbose output
  --version               Show version
  -h, --help              Show help

Examples:
  yaml-lint config.yml
  yaml-lint --schema kubernetes deployment.yml
  yaml-lint --format json --output report.json src/
  yaml-lint --fix --config .yamllint.yml .
```

### Rule Interface

```eiffel
deferred class
    LINT_RULE

feature -- Identification

    name: STRING
            -- Rule unique identifier (e.g., "indent")
        deferred
        end

    description: STRING
            -- Human-readable description
        deferred
        end

    category: STRING
            -- Rule category (syntax, formatting, structure, best-practice)
        deferred
        end

    severity: INTEGER
            -- Default severity: Error (1), Warning (2), Info (3)
        deferred
        end

feature -- Checking

    check (a_context: LINT_CONTEXT): ARRAYED_LIST [LINT_VIOLATION]
            -- Check file and return violations
        require
            context_not_void: a_context /= Void
            context_has_content: not a_context.content.is_empty
        deferred
        ensure
            result_not_void: Result /= Void
        end

feature -- Fix Support

    is_fixable: BOOLEAN
            -- Can this rule auto-fix violations?
        do
            Result := False
        end

    fix (a_violation: LINT_VIOLATION; a_context: LINT_CONTEXT): STRING
            -- Return fixed content for violation
        require
            fixable: is_fixable
            violation_from_this_rule: a_violation.rule_name.is_equal (name)
        do
            Result := a_context.content
        end

feature -- Configuration

    default_options: HASH_TABLE [ANY, STRING]
            -- Default configuration options
        do
            create Result.make (5)
        end

end
```

### Violation Structure

```eiffel
class
    LINT_VIOLATION

create
    make

feature -- Access

    rule_name: STRING
            -- Name of rule that generated this violation

    message: STRING
            -- Human-readable violation message

    file_path: STRING
            -- Path to file with violation

    line_number: INTEGER
            -- Line number (1-based)

    column_number: INTEGER
            -- Column number (1-based)

    severity: INTEGER
            -- 1=Error, 2=Warning, 3=Info

    fixable: BOOLEAN
            -- Can this violation be auto-fixed?

    context_snippet: detachable STRING
            -- Code snippet around violation

feature -- Output

    to_text: STRING
            -- Format as text line
        do
            Result := file_path + ":" + line_number.out + ":" +
                      column_number.out + " [" + rule_name + "] " + message
        end

    to_json: STRING
            -- Format as JSON object
        do
            -- JSON formatting
        end

end
```

### Configuration Schema

**.yamllint.yml:**
```yaml
yaml-lint:
  version: "1.0"

  # Global settings
  extends: recommended  # recommended, strict, minimal, or custom path
  ignore:
    - "vendor/**"
    - "node_modules/**"
    - "*.generated.yml"

  # Rule configuration
  rules:
    # Syntax rules
    valid-yaml: error
    no-duplicate-keys: error

    # Formatting rules
    indent:
      severity: warning
      spaces: 2
      indent-sequences: true
    line-length:
      severity: warning
      max: 120
      allow-non-breakable-words: true
    trailing-spaces: warning
    newline-at-eof: warning

    # Structure rules
    max-depth:
      severity: warning
      max: 5
    required-keys:
      severity: error
      keys: ["apiVersion", "kind"]  # For Kubernetes
      paths: ["*.k8s.yml"]

    # Best practices
    no-hardcoded-secrets:
      severity: error
      patterns:
        - "password"
        - "secret"
        - "api_key"
        - "token"
    lowercase-keys: warning

    # Custom rules
    my-company-rule:
      enabled: true
      options:
        custom-option: value

  # Schema validation
  schemas:
    - pattern: "deployment*.yml"
      schema: kubernetes/deployment
    - pattern: "docker-compose*.yml"
      schema: docker-compose
    - pattern: "*.custom.yml"
      schema: "./schemas/custom-schema.json"

  # Output configuration
  output:
    format: text
    color: auto
    show-snippets: true
```

### Error Handling

| Error Type | Handling | User Message |
|------------|----------|--------------|
| FileNotFound | Skip file, log warning | "File not found: {path}, skipping" |
| ParseError | Report as violation | "YAML parse error at line {n}: {message}" |
| ConfigError | Exit with error | "Invalid config at {key}: {message}" |
| SchemaLoadError | Exit with error | "Cannot load schema: {path}" |
| RuleError | Disable rule, warn | "Rule '{name}' failed: {error}, disabled" |
| PermissionDenied | Skip file, log warning | "Cannot read: {path}, skipping" |

### Data Flow

```
                    +------------------+
                    |   File Paths     |
                    +--------+---------+
                             |
                             v
                    +--------+---------+
                    |   LINT_CLI       |
                    |   file discovery |
                    +--------+---------+
                             |
              +--------------+--------------+
              |              |              |
              v              v              v
        +-----+----+   +-----+----+   +-----+----+
        | file1.yml|   | file2.yml|   | file3.yml|
        +-----+----+   +-----+----+   +-----+----+
              |              |              |
              v              v              v
        +-----+-----------------------------+----+
        |           LINT_ENGINE                   |
        |  for each file:                         |
        |    1. Parse YAML (simple_yaml)          |
        |    2. Create LINT_CONTEXT               |
        |    3. Apply each enabled rule           |
        |    4. Collect violations                |
        +-----+-----------------------------+----+
                             |
                             v
                    +--------+---------+
                    |   LINT_RESULT    |
                    |   all violations |
                    +--------+---------+
                             |
              +--------------+--------------+
              |              |              |
              v              v              v
        +-----+----+   +-----+----+   +-----+----+
        | FIX_ENGINE|  | LINT_OUTPUT|  |LINT_REPORTER|
        | (if --fix)|  | format    |  | summary    |
        +-----+----+   +-----+----+   +-----+----+
              |              |              |
              v              v              v
        +-----+----+   +-----+----+   +-----+----+
        | fixed    |   | stdout/  |   | report   |
        | files    |   | file     |   | file     |
        +----------+   +----------+   +----------+
```

## GUI/TUI Future Path

**CLI foundation enables:**

1. **TUI Mode (simple_tui):**
   - Interactive rule configuration
   - Real-time linting feedback as you type
   - Violation browser with jump-to-line
   - Fix preview and confirmation

2. **GUI Application (future):**
   - Visual rule editor
   - Configuration wizard
   - Violation dashboard with charts
   - Integration with IDEs via LSP

3. **Shared Components:**
   - LINT_ENGINE, RULE_REGISTRY, all rules are UI-agnostic
   - LINT_OUTPUT already supports multiple formats
   - FIX_ENGINE can be used interactively or batch

## Performance Considerations

1. **Parallel Processing:** Lint multiple files concurrently
2. **Lazy Parsing:** Only parse YAML if syntax rule passes
3. **Rule Caching:** Cache compiled regex patterns
4. **Incremental Linting:** Cache results, only re-lint changed files
5. **Memory Efficiency:** Stream large files instead of loading fully
