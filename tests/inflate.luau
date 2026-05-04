local fs = require("@lune/fs")

local frktest = require("../luau_packages/frktest")
local check = frktest.assert.check

local inflate = require("../lib/inflate")

local TEST_CASES = require("./data/inflate/cases")

return function(test: typeof(frktest.test))
	test.suite("Inflate decompression tests", function()
		for _, case in TEST_CASES do
			test.case(`Decompresses {case.name} correctly`, function()
				local filename = `tests/data/inflate/{case.name}.flate`
				local compressedData = fs.readFile(filename)
				local compressed = buffer.fromstring(compressedData)

				local decompressed = inflate(compressed, #case.data)
				local result = buffer.tostring(decompressed)

				check.equal(result, case.data)
			end)
		end

		test.case("Decompresses without knowing uncompressed size", function()
			local compressedData = fs.readFile("tests/data/inflate/repeated_a.flate")
			local compressed = buffer.fromstring(compressedData)

			local decompressed = inflate(compressed)
			local result = buffer.tostring(decompressed)

			check.equal(result, string.rep("a", 100))
		end)

		test.case("Handles large decompression with growth", function()
			local compressedData = fs.readFile("tests/data/inflate/repeated_long.flate")
			local compressed = buffer.fromstring(compressedData)

			local decompressed = inflate(compressed)
			local result = buffer.tostring(decompressed)

			check.equal(#result, 2324)
			check.equal(result, string.rep("x", 2324))
		end)
	end)
end
