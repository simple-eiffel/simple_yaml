# simple_yaml

YAML parser and writer for Eiffel.

Part of the [Simple Eiffel](https://github.com/simple-eiffel) ecosystem.

## Status

**Planned** - Backend for simple_codec

## Overview

Parses and writes [YAML](https://yaml.org/) format files.

```eiffel
yaml: SIMPLE_YAML
data: YAML_MAPPING

create yaml
data := yaml.parse_file ("config.yaml")

name := data.string_item ("name")
```

## Features (Planned)

- YAML 1.2 spec compliance
- Mappings and sequences
- All YAML data types
- Multi-document support
- Anchors and aliases
- Flow and block styles

## License

MIT License
