# YAML Migrate - Technical Design

## Architecture

### Component Overview

```
+------------------------------------------------------------------+
|                        YAML Migrate                               |
+------------------------------------------------------------------+
|  CLI Interface Layer                                              |
|    - MIGRATE_CLI          : Argument parsing, command routing     |
|    - MIGRATE_OUTPUT       : Output formatting and reporting       |
+------------------------------------------------------------------+
|  Conversion Engine                                                |
|    - CONVERT_ENGINE       : Orchestrates conversions              |
|    - FORMAT_DETECTOR      : Auto-detect input format              |
|    - CONVERT_CONTEXT      : Conversion context and options        |
+------------------------------------------------------------------+
|  Format Handlers                                                  |
|    - YAML_HANDLER         : YAML read/write                       |
|    - JSON_HANDLER         : JSON read/write                       |
|    - TOML_HANDLER         : TOML read/write                       |
|    - ENV_HANDLER          : Env file read/write                   |
|    - INI_HANDLER          : INI file read/write                   |
|    - PROPERTIES_HANDLER   : Java properties read/write            |
+------------------------------------------------------------------+
|  Common Data Model                                                |
|    - CONFIG_NODE          : Abstract config node                  |
|    - CONFIG_MAPPING       : Key-value mapping                     |
|    - CONFIG_SEQUENCE      : Ordered list                          |
|    - CONFIG_SCALAR        : Leaf value                            |
+------------------------------------------------------------------+
|  Schema Migration                                                 |
|    - SCHEMA_MIGRATOR      : Apply schema transformations          |
|    - MIGRATION_RULE       : Single transformation rule            |
|    - MIGRATION_SPEC       : Migration specification               |
+------------------------------------------------------------------+
|  Verification                                                     |
|    - VERIFY_ENGINE        : Compare configurations                |
|    - DIFF_ENGINE          : Compute structural differences        |
|    - ROUNDTRIP_TESTER     : Test round-trip fidelity              |
+------------------------------------------------------------------+
|  Batch Processing                                                 |
|    - BATCH_PROCESSOR      : Process multiple files                |
|    - FILE_MAPPER          : Map input to output paths             |
+------------------------------------------------------------------+
|  Integration Layer                                                |
|    - simple_yaml          : YAML support                          |
|    - simple_json          : JSON support                          |
|    - simple_toml          : TOML support                          |
|    - simple_env           : Env file support                      |
|    - simple_file          : File operations                       |
|    - simple_cli           : CLI framework                         |
|    - simple_diff          : Diff computation                      |
+------------------------------------------------------------------+
```

### Class Design

| Class | Responsibility | Key Features |
|-------|----------------|--------------|
| MIGRATE_CLI | Command-line interface | parse_args, route_command, execute |
| CONVERT_ENGINE | Conversion orchestration | convert, batch_convert, verify |
| FORMAT_DETECTOR | Auto-detect format | detect_format, confidence_score |
| YAML_HANDLER | YAML format operations | read, write, to_config_node, from_config_node |
| JSON_HANDLER | JSON format operations | read, write, to_config_node, from_config_node |
| TOML_HANDLER | TOML format operations | read, write, to_config_node, from_config_node |
| ENV_HANDLER | Env file operations | read, write, flatten, unflatten |
| CONFIG_NODE | Abstract config data | is_mapping, is_sequence, is_scalar |
| CONFIG_MAPPING | Key-value pairs | items, keys, put, item |
| CONFIG_SEQUENCE | Ordered values | items, count, item, extend |
| CONFIG_SCALAR | Leaf values | value, type, as_string, as_integer |
| SCHEMA_MIGRATOR | Schema transformation | migrate, apply_rules |
| MIGRATION_RULE | Single transformation | apply, matches, transform |
| VERIFY_ENGINE | Compare configs | are_equivalent, differences |
| DIFF_ENGINE | Structural diff | compute_diff, format_diff |
| BATCH_PROCESSOR | Multi-file processing | process_directory, map_paths |

### Command Structure

```bash
yaml-migrate <command> [options] <files...>

Conversion Commands:
  json2yaml <file>        Convert JSON to YAML
  yaml2json <file>        Convert YAML to JSON
  toml2yaml <file>        Convert TOML to YAML
  yaml2toml <file>        Convert YAML to TOML
  env2yaml <file>         Convert env file to YAML
  yaml2env <file>         Convert YAML to env file
  ini2yaml <file>         Convert INI to YAML
  convert <file>          Auto-detect and convert

Batch Commands:
  batch <command> <files> Batch convert multiple files

Schema Commands:
  migrate <file>          Apply schema migration
  generate-schema <file>  Generate migration schema

Verification Commands:
  verify <a> <b>          Verify files are equivalent
  diff <a> <b>            Show differences
  roundtrip <file>        Test round-trip conversion

Utility Commands:
  detect <file>           Detect file format
  info <file>             Show structure information

Global Options:
  -o, --output FILE       Output file (default: stdout)
  -d, --output-dir DIR    Output directory (for batch)
  --to FORMAT             Target format
  --pretty                Pretty-print output
  --compact               Compact output
  --preserve-order        Preserve key ordering
  --dry-run               Preview without writing
  --force                 Overwrite existing files
  --quiet                 Suppress progress output
  --verbose               Verbose output
  -h, --help              Show help
  --version               Show version

Examples:
  yaml-migrate json2yaml config.json
  yaml-migrate json2yaml config.json -o config.yml
  yaml-migrate batch json2yaml src/*.json -d dest/
  yaml-migrate convert config.txt --to yaml
  yaml-migrate verify original.json converted.yml
```

### Common Data Model

```eiffel
deferred class
    CONFIG_NODE

feature -- Type queries

    is_mapping: BOOLEAN
            -- Is this a key-value mapping?
        deferred
        end

    is_sequence: BOOLEAN
            -- Is this an ordered sequence?
        deferred
        end

    is_scalar: BOOLEAN
            -- Is this a leaf value?
        deferred
        end

feature -- Conversion

    as_mapping: CONFIG_MAPPING
            -- View as mapping
        require
            is_mapping: is_mapping
        deferred
        end

    as_sequence: CONFIG_SEQUENCE
            -- View as sequence
        require
            is_sequence: is_sequence
        deferred
        end

    as_scalar: CONFIG_SCALAR
            -- View as scalar
        require
            is_scalar: is_scalar
        deferred
        end

feature -- Comparison

    is_equivalent (a_other: CONFIG_NODE): BOOLEAN
            -- Are contents equivalent?
        deferred
        end

end
```

### Format Handler Interface

```eiffel
deferred class
    FORMAT_HANDLER

feature -- Identification

    format_name: STRING
            -- Format identifier (yaml, json, toml, env)
        deferred
        end

    extensions: ARRAYED_LIST [STRING]
            -- File extensions for this format
        deferred
        end

feature -- Reading

    read_file (a_path: STRING): CONFIG_NODE
            -- Read file and return config node
        require
            file_exists: (create {RAW_FILE}.make (a_path)).exists
        deferred
        ensure
            result_not_void: Result /= Void
        end

    read_string (a_content: STRING): CONFIG_NODE
            -- Parse string and return config node
        require
            content_not_empty: not a_content.is_empty
        deferred
        end

feature -- Writing

    write_file (a_node: CONFIG_NODE; a_path: STRING)
            -- Write config node to file
        require
            node_not_void: a_node /= Void
        deferred
        end

    to_string (a_node: CONFIG_NODE): STRING
            -- Convert config node to string
        require
            node_not_void: a_node /= Void
        deferred
        ensure
            result_not_empty: not Result.is_empty
        end

feature -- Options

    set_pretty (a_value: BOOLEAN)
            -- Enable/disable pretty printing
        deferred
        end

    set_preserve_order (a_value: BOOLEAN)
            -- Enable/disable key order preservation
        deferred
        end

end
```

### Data Flow

```
                     +------------------+
                     |   Input File     |
                     +--------+---------+
                              |
                              v
                     +--------+---------+
                     | FORMAT_DETECTOR  |
                     | detect format    |
                     +--------+---------+
                              |
                              v
                     +--------+---------+
                     | SOURCE_HANDLER   |
                     | (YAML/JSON/...)  |
                     +--------+---------+
                              |
                              v
                     +--------+---------+
                     | CONFIG_NODE      |
                     | (common model)   |
                     +--------+---------+
                              |
              +---------------+---------------+
              |                               |
              v                               v
     +--------+---------+            +--------+---------+
     | SCHEMA_MIGRATOR  |            | Direct conversion|
     | (if migration)   |            | (if simple)      |
     +--------+---------+            +--------+---------+
              |                               |
              +---------------+---------------+
                              |
                              v
                     +--------+---------+
                     | TARGET_HANDLER   |
                     | (YAML/JSON/...)  |
                     +--------+---------+
                              |
                              v
                     +--------+---------+
                     | VERIFY_ENGINE    |
                     | (if --verify)    |
                     +--------+---------+
                              |
                              v
                     +------------------+
                     |   Output File    |
                     +------------------+
```

### Migration Schema

**migration.yml:**
```yaml
migration:
  name: "v1-to-v2"
  description: "Migrate config from v1 to v2 format"

  rules:
    # Rename a key
    - type: rename
      from: "old_key"
      to: "new_key"

    # Move a key to nested location
    - type: move
      from: "flat_setting"
      to: "settings.nested.value"

    # Transform value
    - type: transform
      path: "timeout"
      transform: "multiply(1000)"  # seconds to ms

    # Add default value
    - type: add
      path: "new_required_field"
      value: "default_value"
      if_missing: true

    # Remove deprecated key
    - type: remove
      path: "deprecated_setting"

    # Conditional transformation
    - type: conditional
      condition: "version < 2"
      then:
        - type: rename
          from: "old_format"
          to: "new_format"

    # Type coercion
    - type: coerce
      path: "port"
      to: integer
```

### Error Handling

| Error Type | Handling | User Message |
|------------|----------|--------------|
| FileNotFound | Exit with error | "File not found: {path}" |
| ParseError | Exit with error | "{format} parse error: {details}" |
| UnsupportedFormat | Exit with error | "Unsupported format: {format}" |
| ConversionError | Exit with error | "Cannot convert {type} to {format}" |
| MigrationError | Exit with error | "Migration rule failed: {rule}" |
| VerificationFailed | Exit with warning | "Verification failed: {differences}" |
| WriteError | Exit with error | "Cannot write to: {path}" |

## GUI/TUI Future Path

**CLI foundation enables:**

1. **TUI Mode (simple_tui):**
   - Interactive format selector
   - Side-by-side preview
   - Migration rule builder
   - Batch progress display

2. **GUI Application (future):**
   - Drag-and-drop file conversion
   - Visual schema mapping editor
   - Batch migration wizard
   - Diff visualization

3. **Shared Components:**
   - All handlers and converters are UI-agnostic
   - CONFIG_NODE model reusable across interfaces
   - VERIFY_ENGINE works for visual and CLI diff

## Performance Considerations

1. **Streaming:** Large files processed in chunks
2. **Parallel Batch:** Multiple files converted concurrently
3. **Lazy Parsing:** Only parse when needed
4. **Memory Efficiency:** Release parsed data after conversion
