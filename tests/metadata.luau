local fs = require("@lune/fs")
local process = require("@lune/process")
local DateTime = require("@lune/datetime")

local frktest = require("../luau_packages/frktest")
local check = frktest.assert.check
local dirs = require("../lune_packages/dirs")

local unzip = require("../lib")

local ZIPS = fs.readDir("tests/data")
local FALLIBLES = {
	"invalid_cde_number_of_files_allocation_greater_offset.zip",
	"invalid_cde_number_of_files_allocation_smaller_offset.zip",
	"invalid_offset.zip",
	"invalid_offset2.zip",
	"invalid_version.zip",
	"misaligned_comment.zip",
	"comment_garbage.zip",
	"chinese.zip", -- FIXME: Support encoding other than UTF-8 and ASCII using OS APIs after FFI
	"max_comment_size.zip", -- NOTE: We test for this in the edge cases suite
}

local METHOD_NAME_TRANSFORMATIONS: { [string]: unzip.CompressionMethod } = {
	["Defl:N"] = "DEFLATE",
	["Stored"] = "STORE",
}

-- Non conclusive translations from host OS zipinfo field and MadeByOS union
local OS_NAME_TRANSFORMATIONS: { [string]: unzip.MadeByOS } = {
	["unx"] = "UNIX",
	["hpf"] = "OS/2",
	["mac"] = "MAC",
	["ntfs"] = "NTFS",
}

local function timestampToValues(dosTimestamp: number): DateTime.DateTimeValues
	local time = bit32.band(dosTimestamp, 0xFFFF)
	local date = bit32.band(bit32.rshift(dosTimestamp, 16), 0xFFFF)

	return {
		year = bit32.band(bit32.rshift(date, 9), 0x7f) + 1980,
		month = bit32.band(bit32.rshift(date, 5), 0x0f),
		day = bit32.band(date, 0x1f),

		hour = bit32.band(bit32.rshift(time, 11), 0x1f),
		minute = bit32.band(bit32.rshift(time, 5), 0x3f),
		second = bit32.band(time, 0x1f) * 2,
	}
end

function dateFuzzyEq(date1: string, date2: string, thresholdDays: number): boolean
	-- Convert the date strings to Lua date tables
	local year1, month1, day1 = date1:match("(%d+)-(%d+)-(%d+)")
	local year2, month2, day2 = date2:match("(%d+)-(%d+)-(%d+)")

	-- Create date tables
	local dt1 =
		os.time({ year = assert(tonumber(year1)), month = assert(tonumber(month1)), day = assert(tonumber(day1)) })
	local dt2 =
		os.time({ year = assert(tonumber(year2)), month = assert(tonumber(month2)), day = assert(tonumber(day2)) })

	-- Calculate the difference in seconds
	local difference = math.abs(dt1 - dt2)

	-- Calculate the threshold in seconds
	local threshold_seconds = thresholdDays * 86400 -- 86400 seconds in a day

	-- Check if the difference is within the threshold
	return difference <= threshold_seconds
end

function timeFuzzyEq(time1: string, time2: string, thresholdSeconds: number): boolean
	-- Convert the time strings to hours, minutes, and seconds
	local hour1, minute1 = time1:match("(%d+):(%d+)")
	local hour2, minute2 = time2:match("(%d+):(%d+)")

	-- Create time tables and convert to seconds
	local totalSeconds1 = (assert(tonumber(hour1)) * 3600) + (assert(tonumber(minute1)) * 60)
	local totalSeconds2 = (assert(tonumber(hour2)) * 3600) + (assert(tonumber(minute2)) * 60)

	-- Calculate the difference in seconds
	local difference = math.abs(totalSeconds1 - totalSeconds2)

	-- Check if the difference is within the threshold
	return difference <= thresholdSeconds
end

return function(test: typeof(frktest.test))
	test.suite("ZIP metadata tests", function()
		for _, file in ZIPS do
			if not string.match(file, "%.zip$") then
				-- Not a zip file, skip
				continue
			end

			local checkErr: ((...any) -> any?) -> nil = if table.find(FALLIBLES, file)
				then check.should_error
				else check.should_not_error

			test.case(`Parsed metadata matches unzip output - {file}`, function()
				checkErr(function()
					file = "tests/data/" .. file
					local data = fs.readFile(file)
					local zip = unzip.load(buffer.fromstring(data))

					-- Fix pipe buffer overload by writing data into temp file and reading the temp file
					local tempFile = dirs.createTempFile()
					local tempFilePath = tempFile.path:toString()

					local command = `unzip -v {file} > {tempFilePath}`
					local execResult = process.exec("sh", { "-lc", command })

					local unzipOutput = fs.readFile(tempFilePath)
					tempFile:removeFile()

					assert(execResult.ok)

					-- Parse unzip output
					for line in string.gmatch(unzipOutput, "[^\r\n]+") do
						if
							not string.match(line, "^Archive:")
							and not string.match(line, "^%s+Length")
							and not string.match(line, "^%s*%-%-%-%-")
							and not string.match(line, "files?$")
							and #line > 0
						then
							local length, method, size, cmpr, expectedDate, expectedTime, crc32, name = string.match(
								line,
								"^%s*(%d+)%s+(%S+)%s+(%d+)%s+([+-]?%d*%%?)%s+(%d%d%d%d%-%d%d%-%d%d)%s+(%d%d:%d%d)%s+(%x+)%s+(.+)$"
							)

							local entry = assert(zip:findEntry(assert(name)))

							if entry.versionMadeBy.os == "UNIX" then
								check.not_nil(entry:unixMode())
							end

							local ok, zipinfoResult = pcall(process.exec, "zipinfo", { file, name })
							if ok then
								-- Errors can only occur when there is a non utf-8 file name, in which case
								-- we skip that file
								assert(zipinfoResult.ok)
								local versionMadeBySoftware, versionMadeByOS =
									string.match(zipinfoResult.stdout, "^.*%s+(%d+%.%d+)%s+(%S+).*$")

								check.equal(versionMadeBySoftware, entry.versionMadeBy.software)
								check.equal(OS_NAME_TRANSFORMATIONS[assert(versionMadeByOS)], entry.versionMadeBy.os)
							end

							local gotCmpr = entry:compressionEfficiency()
							local gotDateTime = DateTime.fromLocalTime(
								timestampToValues(entry.timestamp) :: DateTime.DateTimeValueArguments
							)

							check.equal(tonumber(length), entry.size)
							check.equal(tonumber(size), entry.compressedSize)

							if gotCmpr ~= nil then
								check.equal(cmpr, gotCmpr .. "%")
							end

							check.equal(METHOD_NAME_TRANSFORMATIONS[method :: string], entry.method)
							check.is_true(
								dateFuzzyEq(gotDateTime:formatLocalTime("%Y-%m-%d"), expectedDate :: string, 1)
							)

							-- TODO: Use extra datetime field
							check.is_true(
								-- Allow a threshold of 26 hours, which is the largest possible gap between any two
								-- timezones
								timeFuzzyEq(gotDateTime:formatLocalTime("%H:%M"), expectedTime :: string, 26 * 3600)
							)

							check.equal(string.format("%08x", entry.crc), crc32)
						end
					end

					return "<test>"
				end)
			end)
		end
	end)
end
