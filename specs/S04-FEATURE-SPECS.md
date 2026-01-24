# S04-FEATURE-SPECS.md
**BACKWASH** | Date: 2026-01-23

## Library: simple_yaml

### SIMPLE_YAML Features

| Feature | Signature | Description |
|---------|-----------|-------------|
| make | | Create YAML processor |
| last_errors | : ARRAYED_LIST[STRING_32] | Parse errors |
| has_errors | : BOOLEAN | Any errors? |
| errors_as_string | : STRING_32 | All errors joined |
| parse | (source: STRING_32): detachable YAML_VALUE | Parse string |
| parse_file | (path: STRING_32): detachable YAML_VALUE | Parse file |
| to_yaml | (value: YAML_VALUE): STRING_32 | Generate block style |
| to_yaml_flow | (value: YAML_VALUE): STRING_32 | Generate flow style |
| to_file | (value: YAML_VALUE; path: STRING_32): BOOLEAN | Write to file |
| new_mapping | : YAML_MAPPING | Create empty mapping |
| new_sequence | : YAML_SEQUENCE | Create empty sequence |
| new_string | (value: STRING_32): YAML_STRING | Create string |
| new_integer | (value: INTEGER_64): YAML_INTEGER | Create integer |
| new_float | (value: REAL_64): YAML_FLOAT | Create float |
| new_boolean | (value: BOOLEAN): YAML_BOOLEAN | Create boolean |
| new_null | : YAML_NULL | Create null |
| value_at | (root: YAML_VALUE; path: STRING_32): detachable YAML_VALUE | Path query |
| string_at | (root: YAML_VALUE; path: STRING_32): detachable STRING_32 | Get string |
| integer_at | (root: YAML_VALUE; path: STRING_32): INTEGER_64 | Get integer |
| boolean_at | (root: YAML_VALUE; path: STRING_32): BOOLEAN | Get boolean |
| mapping_at | (root: YAML_VALUE; path: STRING_32): detachable YAML_MAPPING | Get mapping |
| sequence_at | (root: YAML_VALUE; path: STRING_32): detachable YAML_SEQUENCE | Get sequence |

### YAML_VALUE Features (Base)

| Feature | Signature | Description |
|---------|-----------|-------------|
| is_string | : BOOLEAN | Is string type? |
| is_integer | : BOOLEAN | Is integer type? |
| is_float | : BOOLEAN | Is float type? |
| is_boolean | : BOOLEAN | Is boolean type? |
| is_null | : BOOLEAN | Is null type? |
| is_sequence | : BOOLEAN | Is sequence type? |
| is_mapping | : BOOLEAN | Is mapping type? |
| as_string | : STRING_32 | Get as string |
| as_integer | : INTEGER_64 | Get as integer |
| as_float | : REAL_64 | Get as float |
| as_boolean | : BOOLEAN | Get as boolean |
| as_sequence | : YAML_SEQUENCE | Get as sequence |
| as_mapping | : YAML_MAPPING | Get as mapping |
| to_yaml | : STRING_32 | Flow style output |
| to_yaml_indented | (indent: INTEGER): STRING_32 | Block style output |

### YAML_MAPPING Features

| Feature | Signature | Description |
|---------|-----------|-------------|
| entries | : HASH_TABLE[YAML_VALUE, STRING_32] | Internal storage |
| key_order | : ARRAYED_LIST[STRING_32] | Insertion order |
| count | : INTEGER | Number of entries |
| item | (key: STRING_32): detachable YAML_VALUE | Get by key |
| keys | : ARRAYED_LIST[STRING_32] | All keys (ordered) |
| is_empty | : BOOLEAN | Empty mapping? |
| has | (key: STRING_32): BOOLEAN | Has key? |
| put | (value: YAML_VALUE; key: STRING_32) | Add/replace |
| remove | (key: STRING_32) | Remove entry |
| wipe_out | | Clear all |
| string_item, integer_item, float_item, boolean_item, mapping_item, sequence_item | | Typed getters |
| with_string, with_integer, with_float, with_boolean, with_mapping, with_sequence, with_null | | Fluent setters |

### YAML_SEQUENCE Features

| Feature | Signature | Description |
|---------|-----------|-------------|
| items | : ARRAYED_LIST[YAML_VALUE] | Internal storage |
| count | : INTEGER | Number of items |
| item | (index: INTEGER): YAML_VALUE | Get by index (1-based) |
| first, last | : YAML_VALUE | First/last item |
| is_empty | : BOOLEAN | Empty sequence? |
| valid_index | (index: INTEGER): BOOLEAN | Valid index? |
| extend | (value: YAML_VALUE) | Append item |
| put | (value: YAML_VALUE; index: INTEGER) | Replace item |
| wipe_out | | Clear all |
| string_item, integer_item, float_item, boolean_item, mapping_item, sequence_item | | Typed getters |

### SIMPLE_YAML_QUICK Features

| Feature | Signature | Description |
|---------|-----------|-------------|
| load | (path: STRING): detachable YAML_VALUE | Load file |
| parse | (yaml: STRING): detachable YAML_VALUE | Parse string |
| get_string | (value: YAML_VALUE; path: STRING): detachable STRING | Get string at path |
| get_integer | (value: YAML_VALUE; path: STRING): INTEGER | Get integer at path |
| get_real | (value: YAML_VALUE; path: STRING): REAL_64 | Get real at path |
| get_boolean | (value: YAML_VALUE; path: STRING): BOOLEAN | Get boolean at path |
| get_list | (value: YAML_VALUE; path: STRING): ARRAYED_LIST[STRING] | Get string list |
| string_from_file, integer_from_file, boolean_from_file | | One-liner file access |
| has_key | (value: YAML_VALUE; path: STRING): BOOLEAN | Path exists? |
| is_valid | (yaml: STRING): BOOLEAN | Valid YAML? |
| last_error | : STRING | Error message |
