# S06-BOUNDARIES.md
**BACKWASH** | Date: 2026-01-23

## Library: simple_yaml

### API Boundaries

#### Public API (SIMPLE_YAML)
- `make` - Constructor
- `parse` / `parse_file` - Parsing
- `to_yaml` / `to_yaml_flow` / `to_file` - Generation
- `new_*` - Factory methods
- `*_at` - Path queries
- `has_errors` / `last_errors` - Error handling

#### Value Types (Public)
- `YAML_VALUE` - Base type queries
- `YAML_STRING` - String scalar
- `YAML_INTEGER` - Integer scalar
- `YAML_FLOAT` - Float scalar
- `YAML_BOOLEAN` - Boolean scalar
- `YAML_NULL` - Null value
- `YAML_MAPPING` - Dictionary-like
- `YAML_SEQUENCE` - List-like

#### Internal Classes (Implementation)
- `YAML_LEXER` - Tokenization (used by parser)
- `YAML_TOKEN` - Token data structure
- `YAML_PARSER` - Tree building (used by facade)

### Export Policies

```eiffel
YAML_PARSER:
  feature {SIMPLE_YAML}
    parse

YAML_LEXER:
  feature {YAML_PARSER}
    tokenize
    next_token

YAML_TOKEN:
  feature {YAML_LEXER, YAML_PARSER}
    -- All features
```

### Integration Points

| External System | Integration Method |
|-----------------|-------------------|
| File System | PLAIN_TEXT_FILE |
| EiffelBase | ARRAYED_LIST, HASH_TABLE |

### Error Propagation

```
Lexer Error -> YAML_PARSER.last_errors
            -> SIMPLE_YAML.last_errors
            -> has_errors = True
```

Parse returns `Void` on error, errors in `last_errors`.
