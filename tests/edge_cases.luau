local fs = require("@lune/fs")
local process = require("@lune/process")
local serde = require("@lune/serde")

local frktest = require("../lune_packages/frktest")
local check = frktest.assert.check

local ZipReader = require("../lib")

return function(test: typeof(frktest.test))
	test.suite("Edge case tests", function()
		test.case("Handles misaligned comment properly", function()
			local data = fs.readFile("tests/data/misaligned_comment.zip")
			local zip = ZipReader.load(buffer.fromstring(data))

			check.equal(zip.comment, "short.")
		end)

		test.case("Handles comment with garbage after properly", function()
			local data = fs.readFile("tests/data/comment_garbage.zip")
			local zip = ZipReader.load(buffer.fromstring(data))

			check.equal(zip.comment, "short.")
		end)

		test.case("Follows symlinks correctly", function()
			-- TODO: More test files with symlinks

			local data = fs.readFile("tests/data/pandoc_soft_links.zip")
			local zip = ZipReader.load(buffer.fromstring(data))

			local entry = assert(zip:findEntry("/pandoc-3.2-arm64/bin/pandoc-lua"))
			assert(entry:isSymlink(), "Entry type must be a symlink")

			local targetPath = zip:extract(entry, { type = "text" }) :: string
			check.equal(targetPath, "pandoc")

			local bin = zip:extract(entry, { type = "text", followSymlinks = true }) :: buffer
			local expectedBin =
				process.exec("unzip", { "-p", "tests/data/pandoc_soft_links.zip", "pandoc-3.2-arm64/bin/pandoc" })
			check.is_true(expectedBin.ok)

			-- Compare hashes instead of the entire binary to improve speed and not print out
			-- the entire binary data in case there's a mismatch
			check.equal(serde.hash("blake3", bin), serde.hash("blake3", expectedBin.stdout))
		end)

		test.case("Extracts files with UTF8 names", function()
			local data = fs.readFile("tests/data/utf8_filenames.zip")
			local zip = ZipReader.load(buffer.fromstring(data))

			local entries = {}
			for _, entry in zip:listDirectory("/") do
				table.insert(entries, entry.name)
			end

			check.equal(#entries, 3)
			check.table.equal(entries, { "file_こんにちは.txt", "file_你好.txt", "file_안녕하세요.txt" })
		end)

		test.case("Errors on invalid extraction version requirement", function()
			local data = fs.readFile("tests/data/invalid_version.zip")
			local zip = ZipReader.load(buffer.fromstring(data))

			check.should_error(function()
				return zip:extractDirectory("/", { type = "text" })
			end)
		end)

		test.case("Efficiently handles ZIP with max length comment", function()
			local data = fs.readFile("tests/data/max_comment_size.zip")
			local zip = ZipReader.load(buffer.fromstring(data))

			local unzipResult = process.exec("unzip", { "-z", "tests/data/max_comment_size.zip" })
			assert(unzipResult.ok)

			local commentData = assert(string.match(unzipResult.stdout, "\n(.*)\n"))

			-- Check that the comment is the same as the one in the ZIP file (only compare hashes)
			check.equal(serde.hash("blake3", commentData), serde.hash("blake3", zip.comment))
		end)

		test.case("Does not over alllocate based on declared entry count in EoCD", function()
			local data = fs.readFile("tests/data/invalid_cde_number_of_files_allocation_smaller_offset.zip")
			local zip = ZipReader.load(buffer.fromstring(data))

			check.is_true(#zip.entries == 0)
		end)
	end)
end
