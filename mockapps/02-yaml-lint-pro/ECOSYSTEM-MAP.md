# YAML Lint Pro - Ecosystem Integration

## simple_* Dependencies

### Required Libraries

| Library | Purpose | Integration Point |
|---------|---------|-------------------|
| simple_yaml | Core YAML parsing | LINT_ENGINE, rule checks |
| simple_json | JSON Schema support, JSON output | SCHEMA_VALIDATOR, LINT_OUTPUT |
| simple_cli | Command-line interface | LINT_CLI |
| simple_file | File system operations | File discovery, reading |
| simple_regex | Pattern matching for rules | RULE_* pattern checks |

### Optional Libraries

| Library | Purpose | When Needed |
|---------|---------|-------------|
| simple_validation | Validation framework | For complex rule composition |
| simple_logger | Structured logging | For verbose/debug mode |
| simple_template | Rule message templating | For custom rule messages |

## Integration Patterns

### simple_yaml Integration

**Purpose:** Parse YAML files for linting

**Usage:**
```eiffel
class LINT_ENGINE

feature -- Linting

    lint_file (a_path: STRING): LINT_RESULT
            -- Lint a single file and return violations
        local
            l_yaml: SIMPLE_YAML
            l_content: STRING
            l_parsed: detachable YAML_VALUE
            l_context: LINT_CONTEXT
        do
            create Result.make
            l_content := read_file (a_path)

            -- First, try to parse
            create l_yaml.make
            l_parsed := l_yaml.parse (l_content)

            if l_yaml.has_errors then
                -- Add parse errors as violations
                across l_yaml.last_errors as err loop
                    Result.add_violation (create {LINT_VIOLATION}.make_parse_error (
                        a_path, err))
                end
            else
                -- Create context for rules
                create l_context.make (a_path, l_content, l_parsed)

                -- Apply each enabled rule
                across enabled_rules as rule loop
                    Result.merge (rule.check (l_context))
                end
            end
        ensure
            result_not_void: Result /= Void
        end

end
```

**Data flow:**
```
File content -> SIMPLE_YAML.parse -> YAML_VALUE tree
                                          |
                    LINT_CONTEXT ---------+
                          |
              Rule 1 -----+
              Rule 2 -----+  --> LINT_RESULT (violations)
              Rule N -----+
```

### simple_json Integration

**Purpose:** JSON Schema validation and JSON output

**Usage:**
```eiffel
class SCHEMA_VALIDATOR

feature -- Validation

    validate (a_yaml: YAML_VALUE; a_schema_path: STRING): ARRAYED_LIST [LINT_VIOLATION]
            -- Validate YAML against JSON Schema
        local
            l_json: SIMPLE_JSON
            l_schema: JSON_OBJECT
            l_yaml_as_json: JSON_VALUE
            l_errors: ARRAYED_LIST [STRING]
        do
            create Result.make (10)

            -- Load schema
            create l_json.make
            if attached l_json.parse_file (a_schema_path) as l_obj then
                l_schema := l_obj.as_object

                -- Convert YAML to JSON for validation
                l_yaml_as_json := yaml_to_json (a_yaml)

                -- Validate against schema
                l_errors := l_json.validate_against_schema (l_yaml_as_json, l_schema)

                across l_errors as err loop
                    Result.extend (create {LINT_VIOLATION}.make_schema_error (err))
                end
            end
        end

feature -- Output

    violations_to_json (a_violations: ARRAYED_LIST [LINT_VIOLATION]): STRING
            -- Format violations as JSON array
        local
            l_json: SIMPLE_JSON
            l_array: JSON_ARRAY
        do
            create l_json.make
            create l_array.make

            across a_violations as v loop
                l_array.extend (violation_to_json_object (v))
            end

            Result := l_json.to_json (l_array)
        end

end
```

### simple_regex Integration

**Purpose:** Pattern matching for lint rules

**Usage:**
```eiffel
class RULE_NO_HARDCODED_SECRETS

inherit
    LINT_RULE

feature -- Checking

    check (a_context: LINT_CONTEXT): ARRAYED_LIST [LINT_VIOLATION]
            -- Check for hardcoded secrets
        local
            l_regex: SIMPLE_REGEX
            l_lines: LIST [STRING]
            l_line_num: INTEGER
        do
            create Result.make (5)
            create l_regex.make

            l_lines := a_context.content.split ('%N')
            l_line_num := 0

            across l_lines as line loop
                l_line_num := l_line_num + 1

                across secret_patterns as pattern loop
                    if l_regex.matches (line, pattern) then
                        Result.extend (create {LINT_VIOLATION}.make (
                            name,
                            "Possible hardcoded secret detected",
                            a_context.file_path,
                            l_line_num,
                            l_regex.last_match_position,
                            severity))
                    end
                end
            end
        end

feature {NONE} -- Patterns

    secret_patterns: ARRAYED_LIST [STRING]
            -- Patterns to detect secrets
        once
            create Result.make (10)
            Result.extend ("(?i)(password|passwd|pwd)\s*[:=]")
            Result.extend ("(?i)(secret|api_key|apikey)\s*[:=]")
            Result.extend ("(?i)(token|auth_token)\s*[:=]")
            Result.extend ("(?i)(private_key|privatekey)\s*[:=]")
        end

end
```

### simple_cli Integration

**Purpose:** Command-line interface framework

**Usage:**
```eiffel
class LINT_CLI

inherit
    SIMPLE_CLI_APPLICATION
        redefine
            application_name,
            application_version,
            register_commands,
            run
        end

feature -- Application

    application_name: STRING = "yaml-lint"

    application_version: STRING = "1.0.0"

feature -- Execution

    run
            -- Execute linting
        local
            l_engine: LINT_ENGINE
            l_result: LINT_RESULT
            l_output: LINT_OUTPUT
        do
            create l_engine.make_with_config (config_path)
            create l_result.make

            -- Lint all specified files
            across files_to_lint as f loop
                l_result.merge (l_engine.lint_file (f))
            end

            -- Output results
            create l_output.make (output_format)
            print (l_output.format (l_result))

            -- Exit with appropriate code
            if l_result.has_errors then
                exit_with_code (1)
            elseif strict_mode and l_result.has_warnings then
                exit_with_code (1)
            end
        end

feature -- Commands

    register_commands
            -- Register subcommands
        do
            register_command (create {CMD_RULES}.make)
        end

end
```

### simple_file Integration

**Purpose:** File discovery and reading

**Usage:**
```eiffel
class LINT_CLI

feature -- File Discovery

    discover_files (a_paths: ARRAYED_LIST [STRING]): ARRAYED_LIST [STRING]
            -- Discover all YAML files from paths
        local
            l_file: SIMPLE_FILE
        do
            create Result.make (50)

            across a_paths as p loop
                create l_file.make (p)

                if l_file.is_directory then
                    -- Recursively find YAML files
                    across l_file.find_recursive ("*.yml") as f loop
                        if not is_ignored (f) then
                            Result.extend (f)
                        end
                    end
                    across l_file.find_recursive ("*.yaml") as f loop
                        if not is_ignored (f) then
                            Result.extend (f)
                        end
                    end
                elseif l_file.exists then
                    Result.extend (p)
                end
            end
        end

    is_ignored (a_path: STRING): BOOLEAN
            -- Is file in ignore list?
        local
            l_file: SIMPLE_FILE
        do
            across ignore_patterns as pattern loop
                create l_file.make (a_path)
                if l_file.matches_glob (pattern) then
                    Result := True
                end
            end
        end

end
```

## Dependency Graph

```
yaml-lint
    |
    +-- simple_yaml (required)
    |       Core YAML parsing
    |
    +-- simple_json (required)
    |       JSON Schema validation, JSON output
    |
    +-- simple_cli (required)
    |       Command-line interface
    |
    +-- simple_file (required)
    |       File discovery and reading
    |
    +-- simple_regex (required)
    |       Pattern matching for rules
    |
    +-- simple_validation (optional)
    |       Complex rule composition
    |
    +-- simple_logger (optional)
    |       Debug/verbose logging
    |
    +-- ISE base (required)
            Standard Eiffel libraries
```

## ECF Configuration

```xml
<?xml version="1.0" encoding="ISO-8859-1"?>
<system name="yaml_lint" uuid="B2C3D4E5-F6A7-8901-BCDE-F23456789012"
        xmlns="http://www.eiffel.com/developers/xml/configuration-1-22-0"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.eiffel.com/developers/xml/configuration-1-22-0
                            http://www.eiffel.com/developers/xml/configuration-1-22-0.xsd">

    <target name="yaml_lint">
        <description>YAML Lint Pro - Core Library</description>
        <root all_classes="true"/>
        <option warning="warning" full_class_checking="true" void_safety="all">
            <assertions precondition="true" postcondition="true"
                        check="true" invariant="true"/>
        </option>
        <setting name="console_application" value="false"/>

        <!-- Source clusters -->
        <cluster name="src" location=".\src\" recursive="true"/>
        <cluster name="rules" location=".\src\rules\" recursive="true"/>

        <!-- Required simple_* dependencies -->
        <library name="simple_yaml"
                 location="$SIMPLE_EIFFEL\simple_yaml\simple_yaml.ecf"/>
        <library name="simple_json"
                 location="$SIMPLE_EIFFEL\simple_json\simple_json.ecf"/>
        <library name="simple_cli"
                 location="$SIMPLE_EIFFEL\simple_cli\simple_cli.ecf"/>
        <library name="simple_file"
                 location="$SIMPLE_EIFFEL\simple_file\simple_file.ecf"/>
        <library name="simple_regex"
                 location="$SIMPLE_EIFFEL\simple_regex\simple_regex.ecf"/>

        <!-- ISE libraries -->
        <library name="base" location="$ISE_LIBRARY\library\base\base.ecf"/>
    </target>

    <!-- CLI executable target -->
    <target name="yaml_lint_cli" extends="yaml_lint">
        <description>YAML Lint Pro - CLI Executable</description>
        <root class="LINT_CLI" feature="make"/>
        <setting name="console_application" value="true"/>
    </target>

    <!-- Test target -->
    <target name="yaml_lint_tests" extends="yaml_lint">
        <description>YAML Lint Pro - Test Suite</description>
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
| simple_yaml | Parse valid/invalid YAML, verify violations |
| simple_json | Validate against schemas, verify JSON output |
| simple_regex | Test pattern matching rules |
| simple_file | Test file discovery, glob patterns |
| simple_cli | Test argument parsing, exit codes |

## Rule Extension Points

Developers can create custom rules by:

1. **Inheriting from LINT_RULE:**
```eiffel
class MY_CUSTOM_RULE

inherit
    LINT_RULE
        redefine
            name, description, category, severity, check
        end

feature -- Implementation
    -- ...
end
```

2. **Registering in RULE_REGISTRY:**
```eiffel
rule_registry.register (create {MY_CUSTOM_RULE})
```

3. **Configuring in .yamllint.yml:**
```yaml
rules:
  my-custom-rule:
    enabled: true
    severity: error
```
