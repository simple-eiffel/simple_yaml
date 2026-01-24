# 7S-06-SIZING.md

**Date**: 2026-01-23

**BACKWASH** | Date: 2026-01-23

## Library: simple_yaml

### Code Metrics

| Class | Lines | Features | Complexity |
|-------|-------|----------|------------|
| SIMPLE_YAML | ~290 | 22 | Low (facade) |
| YAML_VALUE | ~130 | 16 | Low (base) |
| YAML_STRING | ~70 | 6 | Low |
| YAML_INTEGER | ~50 | 4 | Low |
| YAML_FLOAT | ~80 | 6 | Low |
| YAML_BOOLEAN | ~50 | 4 | Low |
| YAML_NULL | ~30 | 3 | Low |
| YAML_MAPPING | ~385 | 32 | Medium |
| YAML_SEQUENCE | ~245 | 20 | Medium |
| YAML_LEXER | ~695 | 35 | High |
| YAML_PARSER | ~495 | 25 | High |
| YAML_TOKEN | ~60 | 8 | Low |
| SIMPLE_YAML_QUICK | ~290 | 18 | Low |

### Total Estimated
- **Lines of Code**: ~2,870
- **Classes**: 13
- **Features**: ~199

### Memory Characteristics
- Value tree: O(nodes)
- Mapping storage: Hash table
- Sequence storage: Array list
- Token list: O(source length)

### Performance Targets
- Parse 100KB YAML: < 500ms
- Generate output: < 100ms
- Path query: O(path depth)
