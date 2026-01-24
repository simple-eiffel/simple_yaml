# S05-CONSTRAINTS.md
**BACKWASH** | Date: 2026-01-23

## Library: simple_yaml

### Technical Constraints

1. **YAML Version**
   - YAML 1.2 core schema targeted
   - Basic 1.1 compatibility

2. **Document Types**
   - Single document per parse
   - No `---` multi-document streams
   - Document start `---` and end `...` recognized

3. **Scalars**
   - String, integer, float, boolean, null
   - Literal block `|` and folded `>`
   - Single and double quoted strings
   - No base-60 integers (e.g., 1:30)
   - No sexagesimal floats

4. **Collections**
   - Block and flow style mappings
   - Block and flow style sequences
   - Keys must be strings (not complex keys)

5. **Anchors and Aliases**
   - Basic support for `&anchor` and `*alias`
   - No merge key `<<` special handling

6. **Tags**
   - Tags recognized but not processed
   - No custom type instantiation

### Dependency Constraints

1. **Self-Contained**
   - No external dependencies
   - Only EiffelBase required

2. **EiffelStudio Version**
   - Requires EiffelStudio 22.05 or later
   - Void-safe mode required

### Performance Constraints

1. **Memory**
   - Full document in memory
   - Token list retained during parse
   - No streaming mode

2. **File Size**
   - Practical limit ~10MB
   - Larger files may be slow

3. **Recursion**
   - Parser uses recursion
   - Very deep nesting may fail
