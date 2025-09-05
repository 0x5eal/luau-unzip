--> Generate markdown documentation from moonwave comments

local process = require("@lune/process")
local serde = require("@lune/serde")

local moonwave = require("@self/moonwave")
local logger = require("@self/log")
local writeMarkdown = require("@self/markdown")

local function extract(input: string): (number, { moonwave.Item }?)
	local res = process.exec("moonwave-extractor", { "extract", input }, {
		stdio = {
			stderr = "forward",
		},
	})

	if not res.ok then
		print()
		logger.log("error", "`moonwave-extractor` failed with exit code", res.code)
		return res.code, nil
	end

	local ok, items: { moonwave.Item } = pcall(serde.decode, "json" :: "json", res.stdout)
	if not ok then
		return 1, nil
	end

	return 0, items
end

local code, items = extract("lib/init.luau")
writeMarkdown("./docs/intro.md", items :: { moonwave.Item })

process.exit(code)
