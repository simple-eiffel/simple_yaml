# 7S-01-SCOPE.md
**BACKWASH** | Date: 2026-01-23

## Library: simple_yaml

### Problem Domain
YAML parsing and generation for Eiffel applications, focused on configuration files and data interchange.

### Core Use Cases
1. Parse YAML configuration files
2. Build YAML documents programmatically
3. Navigate YAML structures with dot-path queries
4. Generate YAML output (block and flow styles)
5. Support common YAML features: mappings, sequences, scalars

### Target Users
- Eiffel developers working with configuration files
- Applications consuming YAML APIs
- DevOps tool integration
- Data serialization scenarios

### Boundaries
- **In Scope**: YAML 1.2 core schema, mappings, sequences, scalars, anchors/aliases, multi-line strings, file I/O
- **Out of Scope**: YAML tags (custom types), multi-document streams, JSON schema compatibility testing

### Success Criteria
- Parse valid YAML documents
- Handle common scalar types (string, integer, float, boolean, null)
- Support nested mappings and sequences
- Generate valid YAML output
- Path-based value access
