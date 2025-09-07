local fs = require("@lune/fs")
local stdio = require("@lune/stdio")
local process = require("@lune/process")

-- stylua: ignore
local function createZip(version: number): buffer
    version = version or math.random(63, 100)
    print("Using version:", version)

    local data = buffer.create(98)
    local pos = 0

    -- Local file header (30 bytes)
    buffer.writeu32(data, pos, 0x04034b50); pos += 4
    print("Local header starts at:", 0)

    -- Track rest of local header position
    buffer.writeu16(data, pos, version); pos += 2
    buffer.writeu16(data, pos, 0); pos += 2 -- flags
    buffer.writeu16(data, pos, 0); pos += 2 -- compression method
    buffer.writeu32(data, pos, 0); pos += 4 -- timestamp
    buffer.writeu32(data, pos, 0); pos += 4 -- crc32
    buffer.writeu32(data, pos, 0); pos += 4 -- compressed size
    buffer.writeu32(data, pos, 0); pos += 4 -- uncompressed size
    buffer.writeu16(data, pos, 0); pos += 2 -- filename length
    buffer.writeu16(data, pos, 0); pos += 2 -- extra field length

    -- Central directory
    local cdOffset = pos
    print("CD fields:")
    buffer.writeu32(data, pos, 0x02014b50); pos += 4 -- signature
    print("- signature:", buffer.readu32(data, cdOffset))
    buffer.writeu16(data, pos, 20); pos += 2 -- version made by
    print("- version made by:", buffer.readu16(data, cdOffset + 4))
    buffer.writeu16(data, pos, version); pos += 2 -- version needed
    print("- version needed:", buffer.readu16(data, cdOffset + 6))
    print("CD additional fields:")
    print("- flags:", buffer.readu16(data, cdOffset + 8))
    print("- compression:", buffer.readu16(data, cdOffset + 10))
    print("- local header offset:", buffer.readu32(data, cdOffset + 42))
    buffer.writeu16(data, pos, 0); pos += 2 -- flags
    buffer.writeu16(data, pos, 0); pos += 2 -- compression
    buffer.writeu32(data, pos, 0); pos += 4 -- timestamp
    buffer.writeu32(data, pos, 0); pos += 4 -- crc32
    buffer.writeu32(data, pos, 0); pos += 4 -- compressed size
    buffer.writeu32(data, pos, 0); pos += 4 -- uncompressed size
    buffer.writeu16(data, pos, 0); pos += 2 -- filename length
    buffer.writeu16(data, pos, 0); pos += 2 -- extra field length
    buffer.writeu16(data, pos, 0); pos += 2 -- comment length
    buffer.writeu16(data, pos, 0); pos += 2 -- disk number
    buffer.writeu16(data, pos, 0); pos += 2 -- internal attrs
    buffer.writeu32(data, pos, 0); pos += 4 -- external attrs
    buffer.writeu32(data, pos, 0); pos += 4 -- local header offset

    -- End of central directory
    print("EoCD fields:")
    buffer.writeu32(data, pos, 0x06054b50); pos += 4 -- signature
    buffer.writeu16(data, pos, 0); pos += 2 -- disk number
    buffer.writeu16(data, pos, 0); pos += 2 -- disk with cd
    buffer.writeu16(data, pos, 1); pos += 2 -- disk entries (1 file)
    print("- disk entries:", buffer.readu16(data, pos - 18))
    buffer.writeu16(data, pos, 1); pos += 2 -- total entries (1 file)
    print("- total entries:", buffer.readu16(data, pos - 16))
    buffer.writeu32(data, pos, 46); pos += 4 -- cd size (fixed size)
    print("- cd size:", buffer.readu32(data, pos - 14))
    buffer.writeu32(data, pos, 30); pos += 4 -- cd offset (fixed offset)
    print("- cd offset:", buffer.readu32(data, pos - 10))
    buffer.writeu16(data, pos, 0); pos += 2 -- comment length

    print("Final buffer size:", pos)
    local result = buffer.create(pos)
    buffer.copy(result, 0, data, 0, pos)
    return result
end

-- Write the invalid ZIP file
local versionNum = assert(tonumber(process.args[1] or stdio.prompt("text", "Version number:")))
local zip = createZip(versionNum)
fs.writeFile("tests/data/invalid_version.zip", zip)
print(`Generated invalid_version.zip with version requirement {versionNum // 10}.{versionNum % 10}`)
