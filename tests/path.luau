local frktest = require("../luau_packages/frktest")
local check = frktest.assert.check

local path = require("../lib/utils/path")

return function(test: typeof(frktest.test))
	test.suite("Path utilities function as expected", function()
		test.case("Canonicalize should handle basic paths", function()
			check.equal(path.canonicalize("foo/bar"), "foo/bar")
			check.equal(path.canonicalize("foo\\bar"), "foo/bar")
		end)

		test.case("Canonicalize should remove current directory markers", function()
			check.equal(path.canonicalize("foo/./bar"), "foo/bar")
			check.equal(path.canonicalize("./foo/bar"), "foo/bar")
		end)

		test.case("Canonicalize should handle parent directory traversal", function()
			check.equal(path.canonicalize("foo/bar/../baz"), "foo/baz")
			check.equal(path.canonicalize("foo/bar/../../baz"), "baz")
		end)

		test.case("isAbsolute should identify Unix-style absolute paths", function()
			check.is_true(path.isAbsolute("/foo/bar"))
			check.is_true(path.isAbsolute("//foo/bar"))
		end)

		test.case("isAbsolute should identify Windows-style absolute paths", function()
			check.is_true(path.isAbsolute("C:\\foo\\bar"))
			check.is_true(path.isAbsolute("\\\\server\\share"))
		end)

		test.case("isAbsolute should identify relative paths", function()
			check.is_false(path.isAbsolute("foo/bar"))
			check.is_false(path.isAbsolute("./foo/bar"))
		end)

		test.case("isRelative should be inverse of isAbsolute", function()
			check.is_false(path.isRelative("/foo/bar"))
			check.is_false(path.isRelative("C:\\foo\\bar"))
			check.is_true(path.isRelative("foo/bar"))
			check.is_true(path.isRelative("./foo/bar"))
		end)

		test.case("isSafe should reject paths with null bytes", function()
			check.is_false(path.isSafe("foo\0bar"))
		end)

		test.case("isSafe should reject absolute paths", function()
			check.is_false(path.isSafe("/foo/bar"))
			check.is_false(path.isSafe("C:\\foo\\bar"))
		end)

		test.case("isSafe should reject paths that escape current directory", function()
			check.is_false(path.isSafe("../foo"))
			check.is_false(path.isSafe("foo/../../bar"))
		end)

		test.case("isSafe should accept safe relative paths", function()
			check.is_true(path.isSafe("foo/bar"))
			check.is_true(path.isSafe("foo/bar/baz"))
		end)

		test.case("Sanitize should remove special components", function()
			check.equal(path.sanitize("../foo/bar"), "foo/bar")
			check.equal(path.sanitize("./foo/bar"), "foo/bar")
			check.equal(path.sanitize("C:\\foo\\bar"), "foo/bar")
			check.equal(path.sanitize("\\\\server\\share\\foo"), "share/foo")
		end)

		test.case("Sanitize should truncate at null bytes", function()
			check.equal(path.sanitize("foo\0bar/baz"), "foo")
		end)

		test.case("Sanitize should convert backslashes to forward slashes", function()
			check.equal(path.sanitize("foo\\bar\\baz"), "foo/bar/baz")
		end)

		test.case("Sanitize should handle empty components", function()
			check.equal(path.sanitize("/foo//bar"), "foo/bar")
		end)
	end)
end
