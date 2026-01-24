# S01-PROJECT-INVENTORY.md
**BACKWASH** | Date: 2026-01-23

## Library: simple_yaml

### Source Files

| File | Path | Purpose |
|------|------|---------|
| simple_yaml.e | src/core/ | Main facade class |
| yaml_value.e | src/core/ | Base value type |
| yaml_mapping.e | src/core/ | Key-value mapping |
| yaml_sequence.e | src/core/ | Ordered list |
| yaml_string.e | src/scalars/ | String value |
| yaml_integer.e | src/scalars/ | Integer value |
| yaml_float.e | src/scalars/ | Float value |
| yaml_boolean.e | src/scalars/ | Boolean value |
| yaml_null.e | src/scalars/ | Null value |
| yaml_lexer.e | src/lexer/ | Tokenizer |
| yaml_token.e | src/lexer/ | Token class |
| yaml_parser.e | src/parser/ | Parser |
| simple_yaml_quick.e | src/ | Quick operations |

### Test Files

| File | Path | Purpose |
|------|------|---------|
| test_app.e | testing/ | Test application entry |
| lib_tests.e | testing/ | Test suite |

### Configuration Files

| File | Purpose |
|------|---------|
| simple_yaml.ecf | Library ECF |
| simple_yaml_tests.ecf | Test target ECF |

### Dependencies
- EiffelBase only (self-contained)

### Directory Structure
```
simple_yaml/
  src/
    core/
      simple_yaml.e
      yaml_value.e
      yaml_mapping.e
      yaml_sequence.e
    scalars/
      yaml_string.e
      yaml_integer.e
      yaml_float.e
      yaml_boolean.e
      yaml_null.e
    lexer/
      yaml_lexer.e
      yaml_token.e
    parser/
      yaml_parser.e
    simple_yaml_quick.e
  testing/
    test_app.e
    lib_tests.e
  research/
  specs/
```
