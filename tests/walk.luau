local fs = require("@lune/fs")
local process = require("@lune/process")

local frktest = require("../luau_packages/frktest")
local check = frktest.assert.check

local ZipReader = require("../lib")

local ZIPS = {
	"tests/data/files_and_dirs.zip",
	"tests/data/symlink.zip",
	"tests/data/extended_timestamp.zip",
}

return function(test: typeof(frktest.test))
	test.suite("ZIP walking tests", function()
		test.case("Walks all entries recursively", function()
			for _, file in ZIPS do
				local data = fs.readFile(file)
				local zip = ZipReader.load(buffer.fromstring(data))

				-- Get entries from our implementation
				local entries = {}
				zip:walk(function(entry)
					if entry.name ~= "/" then
						table.insert(entries, entry:getPath())
					end
				end)
				table.sort(entries)

				-- Get entries from unzip command
				local result = process.exec("unzip", { "-l", file })
				check.is_true(result.ok)

				-- Parse unzip output into sorted array
				local unzipEntries = {}
				for line in string.gmatch(result.stdout, "[^\r\n]+") do
					-- Skip header/footer lines and empty lines
					if
						not string.match(line, "^Archive:")
						and not string.match(line, "^%s+Length")
						and not string.match(line, "^%s*%-%-%-%-")
						and not string.match(line, "^%s+%d+%s+%d+ files?$")
						and #line > 0
					then
						-- Extract filename from unzip output format
						local name = string.match(line, "%S+$")
						if name then
							table.insert(unzipEntries, name)
						end
					end
				end
				table.sort(unzipEntries)

				-- Compare results
				check.table.equal(entries, unzipEntries)
			end
		end)

		test.case("Walks with correct depth values", function()
			for _, file in ZIPS do
				local data = fs.readFile(file)
				local zip = ZipReader.load(buffer.fromstring(data))

				-- Verify depth values increase correctly
				local rootSeen = false

				zip:walk(function(entry, depth)
					if entry:getPath() == "/" then
						check.equal(depth, 0)
						rootSeen = true
						return
					end

					-- Count path separators to verify depth, starting at 1 for `/`
					local expectedDepth = 1
					for _ in string.gmatch(entry:getPath():gsub("/$", ""), "/") do
						expectedDepth += 1
					end

					check.equal(depth, expectedDepth)
				end)

				check.is_true(rootSeen)
			end
		end)
	end)
end
