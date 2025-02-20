local process = require("@lune/process")
local serde = require("@lune/serde")

local Moonwave = {}

function Moonwave.getFunctionsOfFunctionType(inputArray: { any }, functionType: string)
	local resultArray = {}

	for _, functionObject in inputArray do
		if functionObject.function_type == functionType then
			table.insert(resultArray, functionObject)
		end
	end

	return resultArray
end

function Moonwave.extractCommentsIntoJson(): moonwaveDataExportArray
	local moonwaveExtractResult = process.spawn("./moonwave-extractor", {
		"extract",
		"lib",
	})

	if not moonwaveExtractResult.ok then
		print(moonwaveExtractResult.stderr)

		return process.exit(1)
	else
		local moonwaveData = serde.decode("json", moonwaveExtractResult.stdout)

		return moonwaveData
	end
end

export type PropertyData = {
	name: string,
	desc: string,
	lua_type: string,
	source: {
		line: number,
		path: string,
	},
}

export type FunctionData = {
	name: string,
	desc: string,
	since: string?,
	unreleased: boolean?,
	source: {
		path: string,
		line: number,
	},
	function_type: "method" | "static",
	returns: {
		{
			desc: string,
			lua_type: string,
		}
	},
	params: {
		{
			name: string,
			desc: string,
			lua_type: string,
		}
	},
}

export type DataExportObject = {
	name: string,
	functions: { FunctionData },
	source: { path: string, line: number },
	properties: { PropertyData },
	inherited: { [string]: { functions: { FunctionData }, properties: { PropertyData } } }?,
	desc: string,
	types: unknown,
	tags: { string }?
}

export type moonwaveDataExportArray = {
	DataExportObject
}

return Moonwave