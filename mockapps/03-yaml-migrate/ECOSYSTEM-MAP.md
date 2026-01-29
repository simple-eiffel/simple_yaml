# YAML Migrate - Ecosystem Integration

## simple_* Dependencies

### Required Libraries

| Library | Purpose | Integration Point |
|---------|---------|-------------------|
| simple_yaml | YAML format support | YAML_HANDLER |
| simple_json | JSON format support | JSON_HANDLER |
| simple_toml | TOML format support | TOML_HANDLER |
| simple_env | Env file support | ENV_HANDLER |
| simple_file | File system operations | All handlers, batch processing |
| simple_cli | Command-line interface | MIGRATE_CLI |
| simple_diff | Diff computation | VERIFY_ENGINE, DIFF_ENGINE |

### Optional Libraries

| Library | Purpose | When Needed |
|---------|---------|-------------|
| simple_regex | Pattern matching | Schema migration transforms |
| simple_validation | Validation rules | Migration rule validation |
| simple_logger | Logging | Verbose/debug mode |

## Integration Patterns

### simple_yaml Integration

**Purpose:** Read and write YAML format

**Usage:**
```eiffel
class YAML_HANDLER

inherit
    FORMAT_HANDLER

feature -- Identification

    format_name: STRING = "yaml"

    extensions: ARRAYED_LIST [STRING]
        once
            create Result.make (2)
            Result.extend ("yml")
            Result.extend ("yaml")
        end

feature -- Reading

    read_file (a_path: STRING): CONFIG_NODE
            -- Read YAML file and convert to CONFIG_NODE
        local
            l_yaml: SIMPLE_YAML
            l_value: detachable YAML_VALUE
        do
            create l_yaml.make
            l_value := l_yaml.parse_file (a_path)

            if attached l_value as v then
                Result := yaml_to_config_node (v)
            else
                create {CONFIG_MAPPING} Result.make_empty
            end
        end

feature -- Writing

    to_string (a_node: CONFIG_NODE): STRING
            -- Convert CONFIG_NODE to YAML string
        local
            l_yaml: SIMPLE_YAML
            l_value: YAML_VALUE
        do
            create l_yaml.make
            l_value := config_node_to_yaml (a_node)

            if is_pretty then
                Result := l_yaml.to_yaml (l_value)
            else
                Result := l_yaml.to_yaml_flow (l_value)
            end
        end

feature {NONE} -- Conversion

    yaml_to_config_node (a_yaml: YAML_VALUE): CONFIG_NODE
            -- Convert YAML_VALUE to CONFIG_NODE
        do
            if a_yaml.is_mapping then
                Result := yaml_mapping_to_config (a_yaml.as_mapping)
            elseif a_yaml.is_sequence then
                Result := yaml_sequence_to_config (a_yaml.as_sequence)
            else
                Result := yaml_scalar_to_config (a_yaml)
            end
        end

    config_node_to_yaml (a_node: CONFIG_NODE): YAML_VALUE
            -- Convert CONFIG_NODE to YAML_VALUE
        local
            l_yaml: SIMPLE_YAML
        do
            create l_yaml.make

            if a_node.is_mapping then
                Result := config_mapping_to_yaml (a_node.as_mapping)
            elseif a_node.is_sequence then
                Result := config_sequence_to_yaml (a_node.as_sequence)
            else
                Result := config_scalar_to_yaml (a_node.as_scalar)
            end
        end

end
```

**Data flow:**
```
YAML file -> SIMPLE_YAML.parse_file -> YAML_VALUE
                                           |
             yaml_to_config_node ----------+---> CONFIG_NODE
                                                     |
             config_node_to_yaml <------------------+
                                           |
             SIMPLE_YAML.to_yaml <---------+---> YAML string
```

### simple_json Integration

**Purpose:** Read and write JSON format

**Usage:**
```eiffel
class JSON_HANDLER

inherit
    FORMAT_HANDLER

feature -- Identification

    format_name: STRING = "json"

    extensions: ARRAYED_LIST [STRING]
        once
            create Result.make (1)
            Result.extend ("json")
        end

feature -- Reading

    read_file (a_path: STRING): CONFIG_NODE
            -- Read JSON file and convert to CONFIG_NODE
        local
            l_json: SIMPLE_JSON
            l_value: detachable JSON_VALUE
        do
            create l_json.make
            l_value := l_json.parse_file (a_path)

            if attached l_value as v then
                Result := json_to_config_node (v)
            else
                create {CONFIG_MAPPING} Result.make_empty
            end
        end

feature -- Writing

    to_string (a_node: CONFIG_NODE): STRING
            -- Convert CONFIG_NODE to JSON string
        local
            l_json: SIMPLE_JSON
            l_value: JSON_VALUE
        do
            create l_json.make
            l_value := config_node_to_json (a_node)

            if is_pretty then
                Result := l_json.to_json_pretty (l_value)
            else
                Result := l_json.to_json (l_value)
            end
        end

end
```

### simple_toml Integration

**Purpose:** Read and write TOML format

**Usage:**
```eiffel
class TOML_HANDLER

inherit
    FORMAT_HANDLER

feature -- Identification

    format_name: STRING = "toml"

    extensions: ARRAYED_LIST [STRING]
        once
            create Result.make (1)
            Result.extend ("toml")
        end

feature -- Reading

    read_file (a_path: STRING): CONFIG_NODE
            -- Read TOML file and convert to CONFIG_NODE
        local
            l_toml: SIMPLE_TOML
            l_value: detachable TOML_VALUE
        do
            create l_toml.make
            l_value := l_toml.parse_file (a_path)

            if attached l_value as v then
                Result := toml_to_config_node (v)
            else
                create {CONFIG_MAPPING} Result.make_empty
            end
        end

end
```

### simple_env Integration

**Purpose:** Read and write environment variable files

**Usage:**
```eiffel
class ENV_HANDLER

inherit
    FORMAT_HANDLER

feature -- Identification

    format_name: STRING = "env"

    extensions: ARRAYED_LIST [STRING]
        once
            create Result.make (1)
            Result.extend ("env")
        end

feature -- Reading

    read_file (a_path: STRING): CONFIG_NODE
            -- Read .env file and convert to CONFIG_NODE
        local
            l_env: SIMPLE_ENV
            l_vars: HASH_TABLE [STRING, STRING]
            l_mapping: CONFIG_MAPPING
        do
            create l_env.make
            l_vars := l_env.load_file (a_path)

            -- Convert flat key-value to potentially nested structure
            if use_nested_mode then
                Result := unflatten_env (l_vars)
            else
                create l_mapping.make
                across l_vars as v loop
                    l_mapping.put (create {CONFIG_SCALAR}.make_string (v), v.key)
                end
                Result := l_mapping
            end
        end

feature -- Writing

    to_string (a_node: CONFIG_NODE): STRING
            -- Convert CONFIG_NODE to .env format
        local
            l_vars: HASH_TABLE [STRING, STRING]
        do
            l_vars := flatten_to_env (a_node)

            create Result.make (l_vars.count * 50)
            across l_vars as v loop
                Result.append (v.key)
                Result.append ("=")
                Result.append (v)
                Result.append ("%N")
            end
        end

feature {NONE} -- Helpers

    unflatten_env (a_vars: HASH_TABLE [STRING, STRING]): CONFIG_NODE
            -- Convert DATABASE_HOST=x to database.host=x
        local
            l_mapping: CONFIG_MAPPING
        do
            create l_mapping.make
            across a_vars as v loop
                put_at_path (l_mapping, v.key.as_lower.replace_substring_all ("_", "."), v)
            end
            Result := l_mapping
        end

    flatten_to_env (a_node: CONFIG_NODE): HASH_TABLE [STRING, STRING]
            -- Convert nested structure to flat KEY=value pairs
        do
            create Result.make (20)
            flatten_recursive (a_node, "", Result)
        end

end
```

### simple_diff Integration

**Purpose:** Compute differences for verification

**Usage:**
```eiffel
class VERIFY_ENGINE

feature -- Verification

    verify_equivalent (a_source, a_target: CONFIG_NODE): BOOLEAN
            -- Are two configs semantically equivalent?
        do
            Result := a_source.is_equivalent (a_target)
        end

    compute_differences (a_source, a_target: CONFIG_NODE): ARRAYED_LIST [STRING]
            -- Get list of differences
        local
            l_diff: SIMPLE_DIFF
            l_source_yaml, l_target_yaml: STRING
            l_yaml_handler: YAML_HANDLER
        do
            create l_yaml_handler.make

            -- Normalize both to YAML for comparison
            l_source_yaml := l_yaml_handler.to_string (a_source)
            l_target_yaml := l_yaml_handler.to_string (a_target)

            create l_diff.make
            Result := l_diff.diff_strings (l_source_yaml, l_target_yaml).changes
        end

feature -- Round-trip Testing

    test_roundtrip (a_source: CONFIG_NODE; a_format: STRING): BOOLEAN
            -- Does converting to format and back preserve data?
        local
            l_handler: FORMAT_HANDLER
            l_converted: STRING
            l_back: CONFIG_NODE
        do
            l_handler := handler_for_format (a_format)
            l_converted := l_handler.to_string (a_source)
            l_back := l_handler.read_string (l_converted)
            Result := a_source.is_equivalent (l_back)
        end

end
```

## Dependency Graph

```
yaml-migrate
    |
    +-- simple_yaml (required)
    |       YAML format support
    |
    +-- simple_json (required)
    |       JSON format support
    |
    +-- simple_toml (required)
    |       TOML format support
    |
    +-- simple_env (required)
    |       Env file support
    |
    +-- simple_file (required)
    |       File system operations
    |
    +-- simple_cli (required)
    |       Command-line interface
    |
    +-- simple_diff (required)
    |       Verification diff
    |
    +-- simple_regex (optional)
    |       Migration patterns
    |
    +-- ISE base (required)
            Standard Eiffel libraries
```

## ECF Configuration

```xml
<?xml version="1.0" encoding="ISO-8859-1"?>
<system name="yaml_migrate" uuid="C3D4E5F6-A7B8-9012-CDEF-345678901234"
        xmlns="http://www.eiffel.com/developers/xml/configuration-1-22-0"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.eiffel.com/developers/xml/configuration-1-22-0
                            http://www.eiffel.com/developers/xml/configuration-1-22-0.xsd">

    <target name="yaml_migrate">
        <description>YAML Migrate - Core Library</description>
        <root all_classes="true"/>
        <option warning="warning" full_class_checking="true" void_safety="all">
            <assertions precondition="true" postcondition="true"
                        check="true" invariant="true"/>
        </option>
        <setting name="console_application" value="false"/>

        <!-- Source clusters -->
        <cluster name="src" location=".\src\" recursive="true"/>
        <cluster name="handlers" location=".\src\handlers\" recursive="true"/>

        <!-- Required simple_* dependencies -->
        <library name="simple_yaml"
                 location="$SIMPLE_EIFFEL\simple_yaml\simple_yaml.ecf"/>
        <library name="simple_json"
                 location="$SIMPLE_EIFFEL\simple_json\simple_json.ecf"/>
        <library name="simple_toml"
                 location="$SIMPLE_EIFFEL\simple_toml\simple_toml.ecf"/>
        <library name="simple_env"
                 location="$SIMPLE_EIFFEL\simple_env\simple_env.ecf"/>
        <library name="simple_file"
                 location="$SIMPLE_EIFFEL\simple_file\simple_file.ecf"/>
        <library name="simple_cli"
                 location="$SIMPLE_EIFFEL\simple_cli\simple_cli.ecf"/>
        <library name="simple_diff"
                 location="$SIMPLE_EIFFEL\simple_diff\simple_diff.ecf"/>

        <!-- ISE libraries -->
        <library name="base" location="$ISE_LIBRARY\library\base\base.ecf"/>
    </target>

    <!-- CLI executable target -->
    <target name="yaml_migrate_cli" extends="yaml_migrate">
        <description>YAML Migrate - CLI Executable</description>
        <root class="MIGRATE_CLI" feature="make"/>
        <setting name="console_application" value="true"/>
    </target>

    <!-- Test target -->
    <target name="yaml_migrate_tests" extends="yaml_migrate">
        <description>YAML Migrate - Test Suite</description>
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
| simple_yaml | Round-trip YAML files |
| simple_json | Round-trip JSON files |
| simple_toml | Round-trip TOML files |
| simple_env | Round-trip .env files |
| simple_diff | Verify equivalence detection |
| simple_file | Test batch file processing |

## Format Handler Registration

```eiffel
class HANDLER_REGISTRY

feature -- Registration

    register_default_handlers
            -- Register all built-in format handlers
        do
            register (create {YAML_HANDLER}.make)
            register (create {JSON_HANDLER}.make)
            register (create {TOML_HANDLER}.make)
            register (create {ENV_HANDLER}.make)
            register (create {INI_HANDLER}.make)
            register (create {PROPERTIES_HANDLER}.make)
        end

    handler_for_format (a_format: STRING): detachable FORMAT_HANDLER
            -- Get handler for format name
        do
            Result := handlers.item (a_format.as_lower)
        end

    handler_for_extension (a_ext: STRING): detachable FORMAT_HANDLER
            -- Get handler for file extension
        do
            across handlers as h loop
                if h.extensions.has (a_ext.as_lower) then
                    Result := h
                end
            end
        end

end
```
