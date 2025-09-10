local fs = require("@lune/fs")
local process = require("@lune/process")

local frktest = require("../luau_packages/frktest")
local check = frktest.assert.check

local ZipReader = require("../lib")

return function(test: typeof(frktest.test))
	test.suite("ZIP listing tests (top-level)", function()
		test.case("Lists all entries correctly", function()
			-- Read our test zip file
			local data = fs.readFile("tests/data/files_and_dirs.zip")
			local zip = ZipReader.load(buffer.fromstring(data))

			-- Get listing from our implementation
			local entries = {}
			for _, entry in zip:listDirectory("/") do
				table.insert(entries, entry:getPath())
			end

			-- Get listing from zip command
			local result = process.exec("zip", { "-sf", "tests/data/files_and_dirs.zip" })
			check.is_true(result.ok)
			local zipOutput = result.stdout

			-- Parse zip command output into sorted array
			local zipEntries = {}
			for line in string.gmatch(zipOutput, "[^\r\n]+") do
				-- Skip header/footer lines
				if not string.match(line, "^Archive contains:") and not string.match(line, "^Total %d+ entries") then
					table.insert(zipEntries, string.match(line, "^%s*(.+)$"))
				end
			end

			-- Compare results
			for _, entry in entries do
				check.not_nil(table.find(zipEntries, entry))
			end
		end)

		test.case("Lists directories correctly", function()
			local data = fs.readFile("tests/data/files_and_dirs.zip")
			local zip = ZipReader.load(buffer.fromstring(data))

			local dirs = {}
			for _, entry in zip:listDirectory("/") do
				if entry.isDirectory then
					table.insert(dirs, entry:getPath())
				end
			end

			-- Verify all directory paths end with /
			for _, dir in dirs do
				check.equal(string.sub(dir, -1), "/")
			end
		end)

		test.case("Directory statistics match", function()
			local data = fs.readFile("tests/data/files_and_dirs.zip")
			local zip = ZipReader.load(buffer.fromstring(data))

			local stats = zip:getStats()

			-- Get file count from zip command
			local result = process.exec("zip", { "-sf", "tests/data/files_and_dirs.zip" })
			check.is_true(result.ok)

			-- Parse file count from last line of zip output
			local fileCount = tonumber(string.match(result.stdout, "Total (%d+) entries.*$"))

			check.equal(stats.fileCount + stats.dirCount, fileCount)
		end)
	end)
end
