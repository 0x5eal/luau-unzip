local fs = require("@lune/fs")
local serde = require("@lune/serde")

local frktest = require("../luau_packages/frktest")
local check = frktest.assert.check

local unzip = require("../lib")

type DecompressionRoutines = { [number]: unzip.DecompressionRoutine }

return function(test: typeof(frktest.test))
	test.suite("Custom decompression tests", function()
		test.case("Overrides existing compression methods", function()
			-- Upvalue flags should be overriden if custom decompress routine is invoked
			local customCalled = false
			local validationPassed = false

			local data = fs.readFile("tests/data/files_and_dirs.zip")
			local zip = unzip.ZipReader.new(buffer.fromstring(data), {
				[0x00] = {
					name = "STORE",
					decompress = function(buf, _, validation)
						customCalled = true
						validationPassed = not validation.skip
						return buf
					end,
				},
			} :: DecompressionRoutines)

			local entry = assert(zip:findEntry("file0.txt"))
			zip:extract(entry, { type = "binary", decompress = true })

			check.is_true(customCalled)
			check.is_true(validationPassed)
		end)

		test.case("Fallback to default when custom method not provided", function()
			local data = fs.readFile("tests/data/data_descriptor.zip")
			local zip = unzip.ZipReader.new(buffer.fromstring(data), {
				-- STORE implementation is provided, but file is DEFLATE compressed and
				-- no custom implementation for it is provided. It should fall back to
				-- the default implementation correctly
				[0x00] = {
					name = "STORE",
					decompress = function(buf, _, validation)
						return buf -- no-op override
					end,
				},
			} :: DecompressionRoutines)

			local entry = assert(zip:findEntry("hello.txt"))
			local content = zip:extract(entry, { type = "text" })

			check.equal(content, "Hello World\n")
		end)

		test.case("Implement new compression method (zstd)", function()
			local data = fs.readFile("tests/data/zstd.zip")
			local zip = unzip.ZipReader.new(buffer.fromstring(data), {
				-- Custom ZSTD implementation, backed by `@lune/serde`
				[0x5D] = {
					name = "ZSTD",
					decompress = function(buf, _, validation)
						local decompressed = serde.decompress("zstd", buffer.tostring(buf))
						local result = buffer.fromstring(decompressed)
						
						if not validation.skip then
							local computed = unzip.crc32(result)
							check.equal(computed, validation.expected)
						end

						return result
					end,
				},
			} :: DecompressionRoutines)

			local entry = assert(zip:findEntry("zstd_test.txt"))
			local content = zip:extract(entry, { type = "text" })

			check.equal(content, "Hello from ZSTD!\n")
		end)
	end)
end