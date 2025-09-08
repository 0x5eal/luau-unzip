# luau-unzip

<a href="https://discord.gg/ATVVsNNv3u"><img alt="Discord" src="https://img.shields.io/discord/385151591524597761?style=plastic&logo=discord&color=%235865F2" /></a>
<a href="https://pesde.dev/packages/0x5eal/unzip"><img alt="Pesde" src="https://img.shields.io/badge/pesde-0x5eal/unzip-F19D1E?&style=plastic&logo=data:image/svg%2bxml;base64,PHN2ZyB2aWV3Qm94PSIwIDAgMTAwIDEwMCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZmlsbC1ydWxlPSJldmVub2RkIiBjbGlwLXJ1bGU9ImV2ZW5vZGQiIGQ9Ik00OS42MDI1IDBMOTIuOTAzOCAyNVY3NUw0OS42MDI1IDEwMEw2LjMwMTI3IDc1VjI1TDQ5LjYwMjUgMFpNMTQuMzAxMyAyOS42MTg4TDQ5LjYwMjUgOS4yMzc2TDg0LjkwMzggMjkuNjE4OFY3MC4zODEyTDQ5LjYwMjUgOTAuNzYyNEwzMy42MTQ4IDgxLjUzMTlWNjcuMzg0OEMzNC41MTY3IDY4LjUwNzEgMzUuNjM4OCA2OS40MjE1IDM2Ljk4MSA3MC4xMjc5QzM4Ljk3MDEgNzEuMTQ4IDQxLjAzNTcgNzEuNjU4IDQzLjE3NzkgNzEuNjU4QzQ2LjQ0MiA3MS42NTggNDkuMTQ1MiA3MC44OTI5IDUxLjI4NzMgNjkuMzYyOUM1My40ODA1IDY3Ljc4MTggNTUuMTEyNiA2NS43NjcyIDU2LjE4MzYgNjMuMzE5QzU3LjA5MTUgNjEuMzM4MiA1Ny42MzIgNTkuMjc0IDU3LjgwNTQgNTcuMTI2M0M1OS44NzIzIDU3Ljc0NTcgNjIuMjE1NyA1OC4wNTU0IDY0LjgzNTYgNTguMDU1NEM2Ny42OTE4IDU4LjA1NTQgNzAuMzY5NSA1Ny42NDczIDcyLjg2ODYgNTYuODMxM0M3NS4zNjc4IDU1Ljk2NDIgNzcuNDA3OSA1NC44MTY3IDc4Ljk4OSA1My4zODg2TDc1Ljc3NTggNDcuODAzOEM3NC41NTE3IDQ4LjkyNTggNzIuOTk2MSA0OS44NDM5IDcxLjEwOSA1MC41NTc5QzY5LjIyMTkgNTEuMjIxIDY3LjIwNzMgNTEuNTUyNSA2NS4wNjUyIDUxLjU1MjVDNjEuMzkyOSA1MS41NTI1IDU4LjY2NDMgNTAuNjg1NCA1Ni44NzkyIDQ4Ljk1MTNDNTYuNzE5NSA0OC43OTYyIDU2LjU2NyA0OC42MzY1IDU2LjQyMTcgNDguNDcyQzU1LjYxMDIgNDcuNTUzOSA1NS4wMjExIDQ2LjQ4OTYgNTQuNjU0NiA0NS4yNzkxTDU0LjY0NDMgNDUuMjQ1Mkw1NC42NjkgNDUuMjc5MUg3OS4yMTg1VjQxLjk4OTRDNzkuMjE4NSAzOS4wMzEzIDc4LjU1NTUgMzYuMzUzNiA3Ny4yMjk0IDMzLjk1NjVDNzUuOTU0MyAzMS41NTkzIDc0LjA5MjcgMjkuNjQ2NyA3MS42NDQ1IDI4LjIxODZDNjkuMjQ3NCAyNi43Mzk1IDY2LjM2NTcgMjYgNjIuOTk5NSAyNkM1OS42ODQzIDI2IDU2LjgwMjcgMjYuNzM5NSA1NC4zNTQ1IDI4LjIxODZDNTEuOTA2NCAyOS42NDY3IDUwLjAxOTMgMzEuNTU5MyA0OC42OTMyIDMzLjk1NjVDNDcuNjc0MyAzNS43OTgzIDQ3LjA0NjkgMzcuODA1NyA0Ni44MTA4IDM5Ljk3ODhDNDUuNjg4OCAzOS43MjggNDQuNDc3OCAzOS42MDI2IDQzLjE3NzkgMzkuNjAyNkM0MS4wMzU3IDM5LjYwMjYgMzguOTcwMSA0MC4xMTI3IDM2Ljk4MSA0MS4xMzI3QzM1LjMxNjIgNDEuOTY1MSAzMy45OTAyIDQzLjE1NDkgMzMuMDAyOCA0NC43MDIzVjQwLjM2NzdIMjAuNjg1NVY0Ni4yNTg1SDI1LjgxMTNWNzcuMDI2NkwxNC4zMDEzIDcwLjM4MTJWMjkuNjE4OFpNNTUuMTk2MSAzNi4wOTg2QzU0LjY1MjggMzcuMTAxNSA1NC4zMzIxIDM4LjEyMTYgNTQuMjM0IDM5LjE1ODhINzEuNzk3NkM3MS43OTc2IDM4LjAzNjcgNzEuNDQwNSAzNi45NDAxIDcwLjcyNjUgMzUuODY5MUM3MC4wNjM0IDM0Ljc0NyA2OS4wNjg5IDMzLjgwMzUgNjcuNzQyOCAzMy4wMzg0QzY2LjQ2NzcgMzIuMjczNCA2NC44ODY3IDMxLjg5MDggNjIuOTk5NSAzMS44OTA4QzYxLjExMjQgMzEuODkwOCA1OS41MDU4IDMyLjI5ODkgNTguMTc5OCAzMy4xMTQ5QzU2LjkwNDcgMzMuODggNTUuOTEwMSAzNC44NzQ1IDU1LjE5NjEgMzYuMDk4NlpNNDkuNjQ1MSA1MS41NjkyQzQ5LjMwNzYgNTAuNjY0MSA0OC44MzgxIDQ5Ljg3MSA0OC4yMzY3IDQ5LjE4OThDNDguMDg4NSA0OS4wMjE5IDQ3LjkzMjMgNDguODYwOSA0Ny43NjgxIDQ4LjcwNjdDNDYuMDg1IDQ3LjA3NDYgNDQuMDQ0OSA0Ni4yNTg1IDQxLjY0NzggNDYuMjU4NUM0MC4xMTc3IDQ2LjI1ODUgMzguNjEzMSA0Ni41NjQ1IDM3LjEzNCA0Ny4xNzY2QzM1Ljg1OTQgNDcuNjc3MyAzNC42ODYzIDQ4LjU0MzggMzMuNjE0OCA0OS43NzU5VjYxLjQ3QzM0LjY4NjMgNjIuNjY2NCAzNS44NTk0IDYzLjUzNzggMzcuMTM0IDY0LjA4NEMzOC42MTMxIDY0LjY5NjEgNDAuMTE3NyA2NS4wMDIxIDQxLjY0NzggNjUuMDAyMUM0NC4wNDQ5IDY1LjAwMjEgNDYuMDg1IDY0LjE4NjEgNDcuNzY4MSA2Mi41NTRDNDkuNDUxMiA2MC45MjE5IDUwLjI5MjggNTguNjAxMiA1MC4yOTI4IDU1LjU5MjFDNTAuMjkyOCA1NC4wNjc5IDUwLjA3NjkgNTIuNzI3IDQ5LjY0NTEgNTEuNTY5MloiIGZpbGw9IiNGRkZGRkYiPjwvcGF0aD4KPC9zdmc+" /></a>
<a href="https://lune-org.github.io/docs"><img alt="Lune" src="https://raw.githubusercontent.com/0x5eal/semver-luau/refs/heads/main/.lune/assets/powered-by-lune.svg" /></a>

A Luau library to unzip and extract files from ZIP archives. The implementation is based on the [PKZip APPNOTE v6.3.9](https://www.pkware.com/documents/APPNOTE/APPNOTE-6.3.9.TXT).

## Features
- Extract files from ZIP archives.
- Supports `INFLATE` and `STORE` decompression methods.
- Traverse and list archive contents.
- Retrieve archive statistics (file count, directory count, total size) and metadata.

## Usage

```luau
local fs = require("@lune/fs")
local zip = require("luau-unzip")

-- Read the ZIP file
local file = fs.readFile("test.zip")

-- Load the ZIP archive
local reader = zip.load(buffer.fromstring(file))

-- Print directory structure
print("Directory structure:")
reader:walk(function(entry, depth)
    local prefix = string.rep("  ", depth)
    local suffix = if not entry.isDirectory
        then string.format(" (%d bytes), content: %s", entry.size, reader:extract(entry, { type = "text" }) :: string)
        else ""
    print(prefix .. entry.name .. suffix)
end)

-- List children of root directory
print("\nChildren of `/`:")
local assets = reader:listDirectory("/")
for _, entry in assets do
    print(string.format("    %s - %s (%s)", entry.name, if entry.isDirectory then "DIR" else "FILE", entry.method))
end

-- Get archive statistics
local stats = reader:getStats()
print("\nArchive stats:")
print("Files:", stats.fileCount)
print("Directories:", stats.dirCount)
print("Total size:", stats.totalSize, "bytes")
```

## MSLV (Minimum Supported Luau Version)
This library requires at least Luau [0.669](https://github.com/luau-lang/luau/releases/tag/0.669) (specifically requires `@self` alias, leading `|`, `buffer` built-in and `idiv` operator support).

## Contributing
Contributions are heavily welcomed! We use Nix Flakes to manage a reproducible development environment. To get started, run `exec nix develop -c $SHELL`, after [installing Nix](https://nixos.wiki/wiki/Nix_Installation_Guide). This is recommended for tests to be consistent, since we rely on `InfoZIP` implementations as sanity checks, although different distributions supply differently patched versions of it.

- We utilize [pesde](https://pesde.dev) for package management. Run `pesde install` to install all dependencies. 
- Before submitting a pull request, make sure you include comprehensive test cases for new features, and make sure all tests pass. Tests can be run with `lune run tests`. Refer to other test suites for examples of how to write your own tests.

## License
This project is licensed under the [MIT] license.

[MIT]: https://compeydev.mit-license.org
