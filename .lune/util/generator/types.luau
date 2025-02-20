local Types = {}

local mappedLuauDataTypes = {
	-- generic Roblox datatypes
	[{ "nil" }] = "https://www.lua.org/pil/2.1.html",
	[{ "boolean", "bool" }] = "https://www.lua.org/pil/2.2.html",
	[{ "number" }] = "https://www.lua.org/pil/2.3.html",
	[{ "string" }] = "https://www.lua.org/pil/2.4.html",
	[{ "table" }] = "https://www.lua.org/pil/2.5.html",
	[{ "tuple", "..." }] = "https://www.lua.org/pil/5.1.html",
	[{ "userdata", "proxy" }] = "https://www.lua.org/pil/28.1.html",
}

function Types.parseLuauType(luaType: string, escapeBracket: boolean?)
	luaType = luaType == "" and "any" or luaType

	if string.sub(luaType, 1, 1) == "!" then
		local path = string.split(string.sub(luaType, 2), "/")
		local fileName = path[1]

		return `[{fileName}](/Classes/{table.concat(path, "/")})`
	end

	local luaTypeCheck = string.gsub(string.lower(luaType), "%W", "")

	if escapeBracket then
		luaType = string.gsub(luaType, "{", "\\{")
	end

	for queryTable, apiUrl in mappedLuauDataTypes do
		if table.find(queryTable, luaTypeCheck) then
			return `[{luaType}]({apiUrl})`
		end
	end

	return luaType
end

return Types