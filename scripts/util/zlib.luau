local serde = require("@lune/serde")
local adler32 = require("./adler32")

export type Level = "Low" | "Fast" | "Default" | "Best"
export type Compressed = {
	raw: buffer,
	level: Level,
}

local ZLIB_MAGIC_BYTE = 0x78
local COMPRESSION_LEVELS: { [number]: Level } = {
	[0x01] = "Low",
	[0x5E] = "Fast",
	[0x9C] = "Default",
	[0xDA] = "Best",
}

local zlib = {}

--- Compresses data using zlib deflate and returns it in a structured format
function zlib.deflate(data: buffer): Compressed
	local zlibCompressed = buffer.fromstring(serde.compress("zlib", data))

	local magic = buffer.readu8(zlibCompressed, 0)
	local level = buffer.readu8(zlibCompressed, 1)
	local raw = buffer.create(buffer.len(zlibCompressed) - 6) -- 2 byte header and 4 byte checksum

	-- zlib uses big endian byte ordering, we need to convert it to little endian
	local checksumOffset = buffer.len(raw) + 2
	local checksum = bit32.bor(
		bit32.lshift(buffer.readu8(zlibCompressed, checksumOffset), 24),
		bit32.lshift(buffer.readu8(zlibCompressed, checksumOffset + 1), 16),
		bit32.lshift(buffer.readu8(zlibCompressed, checksumOffset + 2), 8),
		buffer.readu8(zlibCompressed, checksumOffset + 3)
	)

	assert(magic == ZLIB_MAGIC_BYTE, "data is not zlib DEFLATE data")
	assert(checksum == adler32(data), "zlib checksum mismatch")
	buffer.copy(raw, 0, zlibCompressed, 2, buffer.len(raw))

	return {
		level = COMPRESSION_LEVELS[level],
		raw = raw,
	}
end

return zlib
