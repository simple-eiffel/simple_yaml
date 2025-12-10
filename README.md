<p align="center">
  <img src="https://raw.githubusercontent.com/simple-eiffel/claude_eiffel_op_docs/main/artwork/LOGO.png" alt="simple_ library logo" width="400">
</p>

# simple_yaml

**[Documentation](https://simple-eiffel.github.io/simple_yaml/)** | **[GitHub](https://github.com/simple-eiffel/simple_yaml)**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Eiffel](https://img.shields.io/badge/Eiffel-25.02-blue.svg)](https://www.eiffel.org/)
[![Design by Contract](https://img.shields.io/badge/DbC-enforced-orange.svg)]()

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
