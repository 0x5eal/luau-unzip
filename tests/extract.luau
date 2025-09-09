local fs = require("@lune/fs")
local process = require("@lune/process")

local frktest = require("../luau_packages/frktest")
local check = frktest.assert.check

local ZipReader = require("../lib")

-- Reuse the same ZIP files from metadata tests
local ZIPS = fs.readDir("tests/data")
local FALLIBLES = {
	"invalid_cde_number_of_files_allocation_greater_offset.zip",
	-- "invalid_cde_number_of_files_allocation_smaller_offset.zip", -- Tested separately in edge cases
	"invalid_offset.zip",
	"invalid_offset2.zip",
	"chinese.zip", -- Contains non local specific encoding which can't be parsed without OS APIs
}

return function(test: typeof(frktest.test))
	test.suite("ZIP extraction tests", function()
		for _, file in ZIPS do
			if not string.match(file, "%.zip$") then
				continue
			end

			local checkErr: ((...any) -> any?) -> nil = if table.find(FALLIBLES, file)
				then check.should_error
				else check.should_not_error

			test.case(`Extracts files correctly - {file}`, function()
				checkErr(function()
					local zipPath = "tests/data/" .. file
					local data = fs.readFile(zipPath)
					local zip = ZipReader.load(buffer.fromstring(data))

					-- Test both string and buffer extraction
					local stringOptions = { type = "text" :: "text", decompress = true }
					local bufferOptions = { type = "binary" :: "binary", decompress = true }

					-- Extract and verify each file
					zip:walk(function(entry)
						if entry.isDirectory then
							return
						end

						-- Extract with unzip for comparison
						-- Fix pipe buffer overload by writing data into temp file and reading the temp file
						local tmpOut = "/tmp/unzip_meta_"
							.. tostring(os.time())
							.. "_"
							.. tostring(math.random(1, 1_000_000_000))
							.. ".txt"

						local command = `unzip -p {zipPath} {entry:getPath()} > {tmpOut}`
						local execResult = process.exec("sh", { "-lc", command })

						local unzipStdout = fs.readFile(tmpOut)
						fs.removeFile(tmpOut)

						-- NOTE: We use assert since we don't know whether to expect true or false
						assert(execResult.ok)

						-- Test string extraction
						local contentString = zip:extract(entry, stringOptions) :: string
						check.equal(#contentString, entry.size)
						check.equal(contentString, unzipStdout)

						-- Test buffer extraction
						local contentBuffer = zip:extract(entry, bufferOptions) :: buffer
						check.equal(buffer.len(contentBuffer), entry.size)
						check.equal(buffer.tostring(contentBuffer), unzipStdout)

						-- Test directory extraction
						local parentPath = entry:getPath():match("(.+)/[^/]*$") or "/"
						local dirContents = zip:extractDirectory(parentPath, stringOptions)
						check.not_nil(dirContents[entry:getPath()])
						check.equal(dirContents[entry:getPath()], unzipStdout)
					end)

					return
				end)
			end)
		end
	end)
end
