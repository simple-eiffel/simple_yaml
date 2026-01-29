# YAML Config Manager - Ecosystem Integration

## simple_* Dependencies

### Required Libraries

| Library | Purpose | Integration Point |
|---------|---------|-------------------|
| simple_yaml | Core YAML parsing and generation | CONFIG_ENGINE, CONFIG_MERGER |
| simple_json | JSON import/export support | CONFIG_OUTPUT, schema validation |
| simple_file | File system operations | CONFIG_STORE, CONFIG_HISTORY |
| simple_cli | Command-line interface framework | CONFIG_CLI |
| simple_diff | Configuration comparison | CONFIG_DIFFER |
| simple_encryption | Secrets encryption/decryption | SECRETS_HANDLER |

### Optional Libraries

| Library | Purpose | When Needed |
|---------|---------|-------------|
| simple_template | Variable substitution in configs | When using ${var} syntax |
| simple_logger | Structured logging | For audit logging feature |
| simple_sql | Persistent audit storage | For enterprise audit features |
| simple_validation | Custom validation rules | For advanced validation |
| simple_toml | TOML import support | When importing from TOML |
| simple_env | Environment file support | When importing from .env files |

## Integration Patterns

### simple_yaml Integration

**Purpose:** Core YAML document handling

**Usage:**
```eiffel
class CONFIG_ENGINE

feature -- Loading

    load_config (a_path: STRING): detachable YAML_VALUE
            -- Load configuration from file
        local
            l_yaml: SIMPLE_YAML
        do
            create l_yaml.make
            Result := l_yaml.parse_file (a_path)
            if l_yaml.has_errors then
                last_errors.append (l_yaml.last_errors)
            end
        ensure
            errors_set: has_errors implies not last_errors.is_empty
        end

    get_value (a_config: YAML_VALUE; a_path: STRING): detachable YAML_VALUE
            -- Get value at dot-path
        local
            l_yaml: SIMPLE_YAML
        do
            create l_yaml.make
            Result := l_yaml.value_at (a_config, a_path)
        end

feature -- Saving

    save_config (a_config: YAML_VALUE; a_path: STRING): BOOLEAN
            -- Save configuration to file
        local
            l_yaml: SIMPLE_YAML
        do
            create l_yaml.make
            Result := l_yaml.to_file (a_config, a_path)
        end

end
```

**Data flow:**
```
File -> SIMPLE_YAML.parse_file -> YAML_VALUE tree
                                      |
              SIMPLE_YAML.value_at ---+--- Query operations
                                      |
              YAML_MAPPING.with_* ----+--- Modification operations
                                      |
SIMPLE_YAML.to_file <- YAML_VALUE ----+
```

### simple_json Integration

**Purpose:** JSON import/export and schema validation

**Usage:**
```eiffel
class CONFIG_OUTPUT

feature -- JSON Export

    to_json (a_config: YAML_VALUE): STRING
            -- Convert YAML config to JSON format
        local
            l_json: SIMPLE_JSON
            l_obj: JSON_OBJECT
        do
            create l_json.make
            l_obj := yaml_to_json_object (a_config)
            Result := l_json.to_json (l_obj)
        end

feature {NONE} -- Conversion

    yaml_to_json_object (a_yaml: YAML_VALUE): JSON_VALUE
            -- Convert YAML value to JSON value
        do
            if a_yaml.is_mapping then
                Result := mapping_to_json (a_yaml.as_mapping)
            elseif a_yaml.is_sequence then
                Result := sequence_to_json (a_yaml.as_sequence)
            elseif a_yaml.is_string then
                create {JSON_STRING} Result.make (a_yaml.as_string)
            elseif a_yaml.is_integer then
                create {JSON_NUMBER} Result.make_integer (a_yaml.as_integer)
            -- ... other types
            end
        end

end
```

### simple_diff Integration

**Purpose:** Configuration comparison and change detection

**Usage:**
```eiffel
class CONFIG_DIFFER

feature -- Comparison

    compute_diff (a_left, a_right: YAML_VALUE): DIFF_RESULT
            -- Compute differences between two configurations
        local
            l_diff: SIMPLE_DIFF
            l_left_yaml, l_right_yaml: STRING
            l_yaml: SIMPLE_YAML
        do
            create l_yaml.make
            l_left_yaml := l_yaml.to_yaml (a_left)
            l_right_yaml := l_yaml.to_yaml (a_right)

            create l_diff.make
            Result := l_diff.diff_strings (l_left_yaml, l_right_yaml)
        end

    format_diff (a_diff: DIFF_RESULT; a_format: STRING): STRING
            -- Format diff for output
        do
            inspect a_format
            when "unified" then
                Result := a_diff.as_unified
            when "side-by-side" then
                Result := a_diff.as_side_by_side
            when "json" then
                Result := a_diff.as_json
            else
                Result := a_diff.as_text
            end
        end

end
```

### simple_encryption Integration

**Purpose:** Secrets encryption and decryption

**Usage:**
```eiffel
class SECRETS_HANDLER

feature -- Encryption

    encrypt_value (a_plaintext: STRING; a_key: STRING): STRING
            -- Encrypt a secret value
        local
            l_crypto: SIMPLE_ENCRYPTION
        do
            create l_crypto.make_with_key (a_key)
            Result := Encrypted_prefix + l_crypto.encrypt_aes256 (a_plaintext)
        ensure
            result_encrypted: Result.starts_with (Encrypted_prefix)
        end

    decrypt_value (a_ciphertext: STRING; a_key: STRING): STRING
            -- Decrypt an encrypted value
        require
            is_encrypted: a_ciphertext.starts_with (Encrypted_prefix)
        local
            l_crypto: SIMPLE_ENCRYPTION
            l_data: STRING
        do
            create l_crypto.make_with_key (a_key)
            l_data := a_ciphertext.substring (Encrypted_prefix.count + 1, a_ciphertext.count)
            Result := l_crypto.decrypt_aes256 (l_data)
        end

feature {NONE} -- Constants

    Encrypted_prefix: STRING = "ENC["

end
```

### simple_cli Integration

**Purpose:** Command-line interface framework

**Usage:**
```eiffel
class CONFIG_CLI

inherit
    SIMPLE_CLI_APPLICATION
        redefine
            application_name,
            application_version,
            register_commands
        end

feature -- Application

    application_name: STRING = "yaml-config"

    application_version: STRING = "1.0.0"

feature -- Commands

    register_commands
            -- Register all CLI commands
        do
            register_command (create {CMD_GET}.make)
            register_command (create {CMD_SET}.make)
            register_command (create {CMD_MERGE}.make)
            register_command (create {CMD_DIFF}.make)
            register_command (create {CMD_VALIDATE}.make)
            register_command (create {CMD_ENV}.make)
            register_command (create {CMD_SECRETS}.make)
            register_command (create {CMD_HISTORY}.make)
            register_command (create {CMD_DEPLOY}.make)
        end

end
```

### simple_file Integration

**Purpose:** File system operations

**Usage:**
```eiffel
class CONFIG_STORE

feature -- File Operations

    load_file (a_path: STRING): detachable STRING
            -- Load file contents
        local
            l_file: SIMPLE_FILE
        do
            create l_file.make (a_path)
            if l_file.exists and l_file.is_readable then
                Result := l_file.read_all
            end
        end

    save_file (a_path: STRING; a_content: STRING): BOOLEAN
            -- Save content to file with backup
        local
            l_file: SIMPLE_FILE
        do
            create l_file.make (a_path)
            if l_file.exists then
                l_file.backup (".bak")
            end
            Result := l_file.write (a_content)
        end

    list_configs (a_directory: STRING): ARRAYED_LIST [STRING]
            -- List all YAML files in directory
        local
            l_file: SIMPLE_FILE
        do
            create l_file.make (a_directory)
            Result := l_file.list_files ("*.yml")
            Result.append (l_file.list_files ("*.yaml"))
        end

end
```

## Dependency Graph

```
yaml-config
    |
    +-- simple_yaml (required)
    |       Core YAML parsing and generation
    |
    +-- simple_json (required)
    |       JSON export and schema support
    |
    +-- simple_cli (required)
    |       Command-line interface framework
    |
    +-- simple_file (required)
    |       File system operations
    |
    +-- simple_diff (required)
    |       Configuration differencing
    |
    +-- simple_encryption (required)
    |       Secrets encryption
    |
    +-- simple_template (optional)
    |       Variable substitution
    |
    +-- simple_logger (optional)
    |       Structured logging
    |
    +-- simple_validation (optional)
    |       Custom validation rules
    |
    +-- simple_sql (optional, enterprise)
    |       Persistent audit storage
    |
    +-- ISE base (required)
            Standard Eiffel libraries
```

## ECF Configuration

```xml
<?xml version="1.0" encoding="ISO-8859-1"?>
<system name="yaml_config" uuid="A1B2C3D4-E5F6-7890-ABCD-EF1234567890"
        xmlns="http://www.eiffel.com/developers/xml/configuration-1-22-0"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.eiffel.com/developers/xml/configuration-1-22-0
                            http://www.eiffel.com/developers/xml/configuration-1-22-0.xsd">

    <target name="yaml_config">
        <description>YAML Config Manager - Core Library</description>
        <root all_classes="true"/>
        <option warning="warning" full_class_checking="true" void_safety="all">
            <assertions precondition="true" postcondition="true"
                        check="true" invariant="true"/>
        </option>
        <setting name="console_application" value="false"/>

        <!-- Source clusters -->
        <cluster name="src" location=".\src\" recursive="true"/>

        <!-- Required simple_* dependencies -->
        <library name="simple_yaml"
                 location="$SIMPLE_EIFFEL\simple_yaml\simple_yaml.ecf"/>
        <library name="simple_json"
                 location="$SIMPLE_EIFFEL\simple_json\simple_json.ecf"/>
        <library name="simple_cli"
                 location="$SIMPLE_EIFFEL\simple_cli\simple_cli.ecf"/>
        <library name="simple_file"
                 location="$SIMPLE_EIFFEL\simple_file\simple_file.ecf"/>
        <library name="simple_diff"
                 location="$SIMPLE_EIFFEL\simple_diff\simple_diff.ecf"/>
        <library name="simple_encryption"
                 location="$SIMPLE_EIFFEL\simple_encryption\simple_encryption.ecf"/>

        <!-- ISE libraries -->
        <library name="base" location="$ISE_LIBRARY\library\base\base.ecf"/>
    </target>

    <!-- CLI executable target -->
    <target name="yaml_config_cli" extends="yaml_config">
        <description>YAML Config Manager - CLI Executable</description>
        <root class="CONFIG_CLI" feature="make"/>
        <setting name="console_application" value="true"/>

        <!-- Optional libraries for full functionality -->
        <library name="simple_template"
                 location="$SIMPLE_EIFFEL\simple_template\simple_template.ecf"/>
        <library name="simple_logger"
                 location="$SIMPLE_EIFFEL\simple_logger\simple_logger.ecf"/>
        <library name="simple_validation"
                 location="$SIMPLE_EIFFEL\simple_validation\simple_validation.ecf"/>
    </target>

    <!-- Test target -->
    <target name="yaml_config_tests" extends="yaml_config">
        <description>YAML Config Manager - Test Suite</description>
        <root class="TEST_APP" feature="make"/>
        <setting name="console_application" value="true"/>

        <library name="simple_testing"
                 location="$SIMPLE_EIFFEL\simple_testing\simple_testing.ecf"/>

        <cluster name="tests" location=".\tests\" recursive="true"/>
    </target>

</system>
```

## Integration Testing Strategy

| Integration | Test Approach |
|-------------|---------------|
| simple_yaml | Parse sample configs, verify round-trip |
| simple_json | Export to JSON, validate structure |
| simple_diff | Compare known configs, verify diff accuracy |
| simple_encryption | Encrypt/decrypt round-trip, key rotation |
| simple_file | Create/read/delete test files |
| simple_cli | Test command parsing, help output |
