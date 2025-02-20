local fs = require("@lune/fs")
local net = require("@lune/net")

local Generator = {}

function Generator.removeLegacyFiles()
	if fs.isDir("docs/classes") then
		fs.removeDir("docs/classes")
	end

	fs.writeDir("docs/classes")
end

function Generator.writeClassName(className: string)
	local classPath = string.split(className, ".")
	local fullPath = "docs/classes/"

	local fileName = table.remove(classPath, #classPath) :: string
	local netSafeFileName = net.urlEncode(fileName, false)

	for index, path in classPath do
		if not fs.isDir(fullPath .. path) then
			fs.writeDir(fullPath .. path)
		end

		fullPath ..= `{path}/`
	end

	fs.writeFile(fullPath .. `{netSafeFileName}.md`, ``)
	return fullPath .. `{netSafeFileName}.md`
end

function Generator.writeClassContent(classPath: string, classContent: string)
	local pathComponents = string.split(classPath, "/")
	local path = "."

	table.remove(pathComponents, #pathComponents)

	for _, component in pathComponents do
		warn(component)
		if not fs.isDir(`{path}/{component}`) then
			fs.writeDir(`{path}/{component}`)

			path ..= `/{component}`
		end
	end
	
	fs.writeFile(classPath, classContent)
end

return Generator