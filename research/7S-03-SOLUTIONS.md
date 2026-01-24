# 7S-03-SOLUTIONS.md
**BACKWASH** | Date: 2026-01-23

## Library: simple_yaml

### Alternative Solutions Evaluated

| Solution | Language | Pros | Cons |
|----------|----------|------|------|
| libyaml | C | Fast, complete | FFI complexity |
| yaml-cpp | C++ | Modern API | C++ FFI very complex |
| PyYAML | Python | Popular | Python dependency |
| snakeyaml | Java | Full-featured | JVM dependency |
| js-yaml | JavaScript | Lightweight | Node.js dependency |

### Why Native Eiffel
1. **No FFI** - Pure Eiffel implementation
2. **DBC integration** - Contracts for all operations
3. **Void safety** - Compile-time null checking
4. **Ecosystem fit** - Consistent with simple_* patterns
5. **Full control** - Can extend as needed

### Architecture Decision
- Custom lexer (YAML_LEXER) for tokenization
- Custom parser (YAML_PARSER) for tree building
- Value type hierarchy (YAML_VALUE descendants)
- Facade pattern (SIMPLE_YAML)

### Trade-offs Accepted
- No schema validation
- No custom tags
- Single-document only
- May not handle all edge cases
