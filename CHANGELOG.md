# Changelog

## [Unreleased] - 2026-10-08

### Fixed
- Emitter now round-trips types: strings that look like numbers (`80`, `1.5`, `1e5`, `0x1F`, `.inf`, `.nan`), booleans/null words in any case (`True`, `NULL`, `Yes`, `y`, `n`), and strings with leading/trailing space or a tab are quoted.
- Empty child mappings/sequences are emitted inline as `{}` / `[]` (they re-read as null before); an empty top-level collection emits `{}` / `[]`.
- Compiler warning cleanup (obsolete `STRING_32.as_string_8` conversions replaced with 32-bit literals).

