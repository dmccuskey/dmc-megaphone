# Changelog

## 0.2.0 (2026-10-01)

### Changed

- The megaphone is now lua-megaphone 1.3.0's, from DMC-Lua-Library's `lib.dmc_lua.lua_megaphone` (it was 1.2.0). From lua-megaphone 1.3.0:
  - `ignore()` no longer raises an error when nothing is listening.
  - `listen()` and `ignore()` take an object as well as a function; the object's `megaphone_event( event )` is called.
- Rebuilt with dmc-corona-boot 1.6.0 and the current DMC-Lua-Library.

### Added

- `VERSION` on the megaphone (`__version` is lua-megaphone's). It's set on the shared object, which every module gets.
- Unit tests: `tests/run_unit.sh`, plain Lua 5.1.

### Removed

- The copy of `Utils.extend()`, which set the global `_extend`; the module uses DMC-Lua-Library's `lua_utils`.

## 0.1.0

- First release: lua-megaphone packaged for Solar2D.
