# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0] - 2025-09-14
Republish of [0.1.4] as a breaking version bump, since migrating to the new Luau require mechanism could inadvertently break for consumers on an older version of Luau. No other changes.

## [0.1.4] - 2025-09-10 [YANKED]
This update adds support for Luau's new require mechanism, bringing support for Lune versions v0.10.0+ and brings some performance improvements.

### Added
- Support for Luau's new require-by-string semantics, bumping MSLV to [0.669](https://github.com/luau-lang/luau/releases/tag/0.669) (Lune v0.10.x).
### Fixed
- Added test for edge-case of maximum comment size in ZIP data
- Fixed test errors not being caught in CI
### Changed
- Added some newlines after heading in documentation generator for better formatting
- Made markdown heading types follow hierarchy in documentation generator
- Added zed editor LSP configs
- Improved performance of the EoCD offset detection algorithm
- Use `bit32.btest` instead `bit32.band` and not-equals check
- Updated internal tools and nix CI infrastructure

## [0.1.3] - 2025-02-23
This is a hotfix release to fix documentation not being displayed properly on the pesde package page.

### Fixed
- Markdown doc file not being named correctly (rename docs/index.md->docs/intro.md)
### Changed
- Made `docsgen` add `@generated` for generated files
- Made `docsgen` include a heading for generated API reference

## [0.1.2] - 2025-02-23 [YANKED]
This update brings documentation and some bug fixes! Your IDE should now display information such as usage and best practices for this library when you hover over any of its exported items. The docs are also available on the web in the markdown format, which can be found on [the pesde package page](https://pesde.dev/packages/0x5eal/unzip/0.1.2/luau/docs/intro).

### Added
- Added doc comments powered by [moonwave](https://github.com/evaera/moonwave) ([#2](https://github.com/0x5eal/luau-unzip/pull/2))
- Added markdown doc generator lune script and configured pesde docs
### Fixed
- Fixed incorrect type signatures for some functions
### Changed
- Applied `stylua` formatter on code
- Bumped and pinned pesde version to v0.6.0

## [0.1.1] - 2025-02-18
### Added
- Added GitHub Actions powered CI workflows
- Started using [`nix`](https://nixos.org/) for reproducible development environments
### Fixed
- Fixed repeated path components when using `ZipEntry:getPath` for some ZIP files
### Changed
- Pinned tooling dependencies (`stylua`, `luau-lsp`, `pesde`, `lune`) in manifest
- README includes contributing guidelines and basic setup instructions
- Updated dependencies

## [0.1.0] - 2025-01-12
`luau-unzip` is finally stable and tested enough for a v0.1.0 release! This release includes important bug fixes and a handful of new features as well. It does also have have breaking changes, so please take a look at the changed section below for those.

### Added
- PKZip version validation before extracting files
- `ZipEntry` now has a `versionMadeBy` field which includes information about the host system and version of the ZIP file
- `ZipEntry` now has a `compressedSize` field which indicates the size of the compressed data
- Added method `ZipEntry:compressionEfficiency` to return compression efficiency in the form of a percentage
- Added method `ZipEntry:unixMode` to parse and extract unix mode information from external file attributes
- Added methods to handle path safety and sanitization were added to `ZipEntry`:
```luau
-- NOTE: All paths returned by methods use `/` as the path separator

-- Returns the path if it is safe, otherwise returns nil
entry:getSafePath()

-- Converts a potentially unsafe path to a safe one, possibly losing some information
entry:sanitizePath()
```
### Changed
- Renamed `isAscii` field for `ZipEntry` to `isText`
- Renamed `isString` option for `ZipReader:extract` to `isText`
### Fixed
- Fixed a bug where `ZipReader:extract` would not correctly error when there was a mismatch between the count of entries specified in the EoCD and the number of entries found
- Removed any typecast for internal decompression utilities due to `table.freeze` interfering with types

## [0.0.1] - 2025-01-07
### Changed
- Improved output format for `tour` example
- Relaxed MSLV requirement to 0.593
- Refactored utilities as separate modules
- Improved test coverage with more edge case tests

## [0.0.1-rc.2] - 2025-01-06
### Added
- Support for symlinks - checking whether an entry is a symlink and following symlinks
```luau
local unzip = require("unzip")

local zip = unzip.load(...)

-- Given a ZIP of the structure: path/to/symlink -> path/to/target
local entry = zip:findEntry("path/to/symlink")

-- The following will return "path/to/target"
local targetPath = zip:extract(entry, { isString = true, followSymlinks = false })
print("Symlink target:", targetPath)

-- The following will return the contents of "path/to/target"
local followedTargetContents = zip:extract(entry, { isString = true, followSymlinks = true })
local targetContents = zip:extract(zip:findEntry("path/to/target"), { isString = true })

-- Following the symlink should give us the contents of the target file
assert(targetContents == followedTargetContents, "Symlink must lead to the target file!")
```
- Added the `isAscii` field and automatic compressed data type detection when the `isString` option is not provided using internal file attributes
### Fixed
- Fixed a bug where ZIPs that contained an end of central directory record with a misaligned comment window would not be correctly read
- Fixed an underflow while trying to align the byte boundary while decompressing uncompressed inflate blocks

## [0.0.1-rc.1] - 2025-01-06
### Added
- Initial library release :tada:

[unreleased]: https://github.com/0x5eal/luau-unzip/commits/HEAD
[0.2.0]: https://pesde.dev/packages/0x5eal/unzip/0.2.0/any
[0.1.4]: https://pesde.dev/packages/0x5eal/unzip/0.1.4/any
[0.1.3]: https://pesde.dev/packages/0x5eal/unzip/0.1.3/any
[0.1.2]: https://pesde.dev/packages/0x5eal/unzip/0.1.2/any
[0.1.1]: https://pesde.dev/packages/0x5eal/unzip/0.1.1/any
[0.1.0]: https://pesde.dev/packages/0x5eal/unzip/0.1.0/any
[0.0.1]: https://pesde.dev/packages/0x5eal/unzip/0.0.1/any
[0.0.1-rc.2]: https://pesde.dev/packages/0x5eal/unzip/0.0.1-rc.2/any
[0.0.1-rc.1]: https://pesde.dev/packages/0x5eal/unzip/0.0.1-rc.1/any
