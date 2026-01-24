# 7S-02-STANDARDS.md
**BACKWASH** | Date: 2026-01-23

## Library: simple_yaml

### Applicable Standards

1. **YAML 1.2** - yaml.org specification
   - Superset of JSON
   - Indentation-based structure
   - Human-readable format

### Core Schema Scalars

| YAML Value | Eiffel Type |
|------------|-------------|
| null, ~ | YAML_NULL |
| true, false, yes, no, on, off | YAML_BOOLEAN |
| 123, -456, +789 | YAML_INTEGER |
| 1.5, -2.5e10, .inf, -.inf, .nan | YAML_FLOAT |
| "text", 'text', text | YAML_STRING |

### Collection Types

| YAML Structure | Eiffel Type |
|----------------|-------------|
| key: value (mapping) | YAML_MAPPING |
| - item (sequence) | YAML_SEQUENCE |

### Block Scalar Styles

| Indicator | Style | Description |
|-----------|-------|-------------|
| \| | Literal | Preserve newlines |
| > | Folded | Fold newlines to spaces |

### Flow Style

```yaml
# Flow mapping
{key: value, key2: value2}

# Flow sequence
[item1, item2, item3]
```

### Anchors and Aliases
```yaml
defaults: &defaults
  timeout: 30

development:
  <<: *defaults
  debug: true
```
