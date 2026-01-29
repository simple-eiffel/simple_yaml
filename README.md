<p align="center">
  <img src="https://raw.githubusercontent.com/simple-eiffel/.github/main/profile/assets/logo.svg" alt="simple_ library logo" width="400">
</p>

# simple_yaml

**[Documentation](https://simple-eiffel.github.io/simple_yaml/)** | **[GitHub](https://github.com/simple-eiffel/simple_yaml)**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Eiffel](https://img.shields.io/badge/Eiffel-25.02-blue.svg)](https://www.eiffel.org/)
[![Design by Contract](https://img.shields.io/badge/DbC-enforced-orange.svg)]()

YAML parser and writer for Eiffel.

Part of the [Simple Eiffel](https://github.com/simple-eiffel) ecosystem.

## Status

**Production** - Full YAML 1.2 parser with dot-path access

## Installation

Set the ecosystem environment variable (one-time setup for all simple_* libraries):
```
SIMPLE_EIFFEL=D:\prod
```

Add to your ECF:
```xml
<library name="simple_yaml" location="$SIMPLE_EIFFEL/simple_yaml/simple_yaml.ecf"/>
```

## Overview

Parses and writes [YAML](https://yaml.org/) format files with convenient dot-path access.

## Quick Start (Zero-Configuration)

Use `SIMPLE_YAML_QUICK` for the simplest possible YAML operations:

```eiffel
local
    yaml: SIMPLE_YAML_QUICK
    config: YAML_VALUE
do
    create yaml.make

    -- Load config file
    config := yaml.load ("config.yml")

    -- Get values with dot-path (like config files!)
    host := yaml.get_string (config, "database.host")
    port := yaml.get_integer (config, "database.port")
    debug := yaml.get_boolean (config, "logging.debug")
    timeout := yaml.get_real (config, "server.timeout")

    -- Get string list
    across yaml.get_list (config, "features.enabled") as f loop
        print (f)
    end

    -- One-liner file access
    host := yaml.string_from_file ("config.yml", "database.host")
    port := yaml.integer_from_file ("config.yml", "database.port")

    -- Check if key exists
    if yaml.has_key (config, "database.ssl") then ...

    -- Parse YAML string
    config := yaml.parse (yaml_string)

    -- Validation
    if yaml.is_valid (yaml_string) then ...

    -- Error handling
    if yaml.has_error then
        print (yaml.last_error)
    end
end
```

## Standard API (Full Control)

```eiffel
yaml: SIMPLE_YAML
data: YAML_MAPPING

create yaml.make
data := yaml.parse_file ("config.yaml")

name := data.string_item ("name")
```

## Features

- YAML 1.2 spec compliance
- Mappings and sequences
- All YAML data types
- Multi-document support
- Anchors and aliases
- Flow and block styles
- Dot-path access for config files

## License

MIT License
