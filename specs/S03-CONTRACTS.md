# S03-CONTRACTS.md
**BACKWASH** | Date: 2026-01-23

## Library: simple_yaml

### SIMPLE_YAML Contracts

```eiffel
parse (a_source: STRING_32): detachable YAML_VALUE
  require
    source_not_void: a_source /= Void

parse_file (a_file_path: STRING_32): detachable YAML_VALUE
  require
    path_not_void: a_file_path /= Void

to_yaml (a_value: YAML_VALUE): STRING_32
  require
    value_not_void: a_value /= Void

to_file (a_value: YAML_VALUE; a_file_path: STRING_32): BOOLEAN
  require
    value_not_void: a_value /= Void
    path_not_void: a_file_path /= Void

value_at (a_root: YAML_VALUE; a_path: STRING_32): detachable YAML_VALUE
  require
    root_not_void: a_root /= Void
    path_not_void: a_path /= Void
```

### YAML_MAPPING Contracts

```eiffel
make
  ensure
    empty: is_empty

item (a_key: STRING_32): detachable YAML_VALUE
  require
    key_not_void: a_key /= Void

put (a_value: YAML_VALUE; a_key: STRING_32)
  require
    value_not_void: a_value /= Void
    key_not_void: a_key /= Void
    key_not_empty: not a_key.is_empty
  ensure
    has_key: has (a_key)
    value_set: item (a_key) = a_value

remove (a_key: STRING_32)
  require
    key_not_void: a_key /= Void
    has_key: has (a_key)
  ensure
    removed: not has (a_key)

with_string (a_key: STRING_32; a_value: STRING_32): like Current
  require
    key_not_void: a_key /= Void
    value_not_void: a_value /= Void
  ensure
    has_key: has (a_key)
```

### YAML_SEQUENCE Contracts

```eiffel
make
  ensure
    empty: is_empty

item (a_index: INTEGER): YAML_VALUE
  require
    valid_index: valid_index (a_index)

extend (a_value: YAML_VALUE)
  require
    value_not_void: a_value /= Void
  ensure
    one_more: count = old count + 1
    last_is_value: last = a_value

put (a_value: YAML_VALUE; a_index: INTEGER)
  require
    value_not_void: a_value /= Void
    valid_index: valid_index (a_index)
  ensure
    replaced: item (a_index) = a_value
    same_count: count = old count
```

### Class Invariants

```eiffel
YAML_MAPPING:
  entries_not_void: entries /= Void
  key_order_not_void: key_order /= Void
  consistent_count: entries.count = key_order.count

YAML_SEQUENCE:
  items_not_void: items /= Void

YAML_PARSER:
  lexer_attached: lexer /= Void
  tokens_attached: tokens /= Void
```
