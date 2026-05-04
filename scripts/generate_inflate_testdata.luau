local fs = require("@lune/fs")
local zlib = require("./util/zlib")
local toHex = require("./util/hex")

local testCases = require("../tests/data/inflate/cases")
local TEST_DATA_DIR = "tests/data/inflate"

print("Generating inflate test files to", TEST_DATA_DIR)
fs.writeDir(TEST_DATA_DIR)

for _, case in testCases do
	local compressed = zlib.deflate(buffer.fromstring(case.data))
	local filename = `{TEST_DATA_DIR}/{case.name}.flate`

	fs.writeFile(filename, buffer.tostring(compressed.raw))
	print(
		string.format(
			"  %-20s %4d byte(s) vs %2d bytes  %s",
			case.name,
			#case.data,
			buffer.len(compressed.raw),
			toHex(case.data, 8)
		)
	)
end
