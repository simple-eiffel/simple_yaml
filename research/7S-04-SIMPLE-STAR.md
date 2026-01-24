# 7S-04-SIMPLE-STAR.md
**BACKWASH** | Date: 2026-01-23

## Library: simple_yaml

### Dependencies on simple_* Ecosystem

| Library | Purpose | Integration Point |
|---------|---------|-------------------|
| None currently | Self-contained | - |

### Ecosystem Patterns Followed

1. **Facade Pattern** - SIMPLE_YAML provides simplified API
2. **Quick Class** - SIMPLE_YAML_QUICK for one-liners
3. **Fluent API** - `with_string`, `with_integer` on YAML_MAPPING
4. **Error Handling** - `has_errors` / `last_errors` pattern

### Class Naming Convention
- `SIMPLE_YAML` - Main facade
- `YAML_*` - Domain classes (VALUE, MAPPING, SEQUENCE, etc.)
- `YAML_LEXER` - Tokenizer
- `YAML_PARSER` - Parser
- `YAML_TOKEN` - Token representation

### Value Type Hierarchy
```
YAML_VALUE (base)
  +-- YAML_STRING
  +-- YAML_INTEGER
  +-- YAML_FLOAT
  +-- YAML_BOOLEAN
  +-- YAML_NULL
  +-- YAML_MAPPING
  +-- YAML_SEQUENCE
```

### Consistent API Design
```eiffel
-- Parse
config := yaml.parse (source)

-- Query
host := yaml.string_at (config, "server.host")

-- Build
mapping := yaml.new_mapping
             .with_string ("name", "value")
             .with_integer ("port", 8080)
```
