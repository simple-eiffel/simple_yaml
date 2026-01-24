# S02-CLASS-CATALOG.md
**BACKWASH** | Date: 2026-01-23

## Library: simple_yaml

### Class Hierarchy

```
ANY
  SIMPLE_YAML              -- Main facade
  YAML_VALUE               -- Base value type
    +-- YAML_STRING        -- String scalar
    +-- YAML_INTEGER       -- Integer scalar
    +-- YAML_FLOAT         -- Float scalar
    +-- YAML_BOOLEAN       -- Boolean scalar
    +-- YAML_NULL          -- Null scalar
    +-- YAML_MAPPING       -- Key-value mapping
    +-- YAML_SEQUENCE      -- Ordered list
  YAML_LEXER               -- Tokenizer
  YAML_TOKEN               -- Token representation
  YAML_PARSER              -- Parser
  SIMPLE_YAML_QUICK        -- Quick operations
```

### Class Descriptions

| Class | Responsibility | Key Collaborators |
|-------|----------------|-------------------|
| SIMPLE_YAML | High-level API facade | YAML_PARSER, YAML_VALUE |
| YAML_VALUE | Base for all values | - |
| YAML_STRING | Hold string value | YAML_VALUE |
| YAML_INTEGER | Hold integer value | YAML_VALUE |
| YAML_FLOAT | Hold float value | YAML_VALUE |
| YAML_BOOLEAN | Hold boolean value | YAML_VALUE |
| YAML_NULL | Represent null | YAML_VALUE |
| YAML_MAPPING | Key-value pairs | YAML_VALUE |
| YAML_SEQUENCE | Ordered collection | YAML_VALUE |
| YAML_LEXER | Tokenize YAML source | YAML_TOKEN |
| YAML_TOKEN | Single token | - |
| YAML_PARSER | Build value tree | YAML_LEXER, YAML_VALUE |
| SIMPLE_YAML_QUICK | One-liner operations | SIMPLE_YAML |

### Creation Procedures

| Class | Creators |
|-------|----------|
| SIMPLE_YAML | make |
| YAML_VALUE | (deferred/base) |
| YAML_STRING | make, make_literal, make_folded |
| YAML_INTEGER | make |
| YAML_FLOAT | make, make_infinity, make_nan |
| YAML_BOOLEAN | make |
| YAML_NULL | make |
| YAML_MAPPING | make |
| YAML_SEQUENCE | make |
| YAML_LEXER | make, default_create |
| YAML_TOKEN | make |
| YAML_PARSER | make, default_create |
| SIMPLE_YAML_QUICK | make |
