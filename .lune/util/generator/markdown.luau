local Moonwave = require("moonwave")
local Types = require("types")

local Markdown = {}

local function comment(source)
	return `[//]: # ({source})\n`
end

local function newline()
	return `\n`
end

local function h1(source)
	return `# {source}\n\n`
end

local function h2(source)
	return `## {source}\n\n`
end

local function h3(source)
	return `### {source}\n\n`
end

local function input(source)
	return `{source}\n`
end

local function separator()
	return `---\n`
end

local function property(name: string, type: string)
	return `<LuaProperty name="{name}" type="{type}" />`
end

local function getReadableParamList(proto: Moonwave.FunctionData)
	local readableList = " "

	if #proto.params == 0 then
		return ""
	end

	for index, paramObject in proto.params do
		readableList ..= `\`{paramObject.name}\` {Types.parseLuauType(paramObject.lua_type, true)}` .. (index == #proto.params and ` ` or `, `)
	end

	return readableList
end

local function getReadableReturnsList(proto: Moonwave.FunctionData)
	local readableList = " "

	if #proto.returns == 0 then
		return Types.parseLuauType("nil")
	end

	for index, returnObject in proto.returns do
		readableList ..= `{Types.parseLuauType(returnObject.lua_type, true)}` .. (index == #proto.returns and ` ` or `, `)
	end

	return readableList
end

local function frontmatter(source: {
	name: string,
	description: string,
	order: number,
})
	return `---\ntitle: {source.name}\ndescription: {source.description}\nsidebar:\n order: {source.order}\n collapsed: true\n---`
end

function Markdown.generateMarkdownDocumentFor(classDocumentation: Moonwave.DataExportObject)
	local markdownFile = ``

	local className = classDocumentation.name:gmatch("%S+%.(%S+)")() or classDocumentation.name
	local classDescription = classDocumentation.desc
	local classProperties = classDocumentation.properties

	local classMethods = Moonwave.getFunctionsOfFunctionType(classDocumentation.functions, "method")
	local classFunctions = Moonwave.getFunctionsOfFunctionType(classDocumentation.functions, "static")

	local sizeOfClassProperties = #classProperties

	local sizeOfClassMethods = #classMethods
	local sizeOfClassFunctions = #classFunctions

	local order = #string.split(classDocumentation.name, ".")

	markdownFile ..= frontmatter({
		name = className,
		description = `luau-unzip docs for {className}.`,
		order = order,
	})

	markdownFile ..= newline()

	markdownFile ..= comment(
		`This file was automatically @generated from moonwave comments using a script. Please do not edit by hand.`
	)
	markdownFile ..= comment(`To edit this documentation, make changes to the main luau-unzip repo.`)

	markdownFile ..= newline()


	markdownFile ..= comment(`----- DOCUMENT INTRODUCTION ----- `)

	markdownFile ..= newline()

	markdownFile ..= h1(className)

	markdownFile ..= input(classDescription)

	markdownFile ..= newline()

	markdownFile ..= comment(`----- DOCUMENT PROPERTIES ----- `)

	markdownFile ..= newline()

	markdownFile ..= h2(`Properties`)

	if sizeOfClassProperties > 0 then
		for _, prop in classProperties do
			markdownFile ..= h3(prop.name)
			markdownFile ..= property(`{className}.{prop.name}`, prop.lua_type)
			markdownFile ..= newline()

			if prop.desc ~= "" then
				markdownFile ..= separator()
				markdownFile ..= input(prop.desc)
			end
		end
	else
		markdownFile ..= input(`The {className} instance has no set properties!`)
	end

	markdownFile ..= newline()

	markdownFile ..= comment(`----- DOCUMENT METHODS ----- `)

	markdownFile ..= newline()

	markdownFile ..= h2(`Methods`)

	if sizeOfClassMethods > 0 then
		for _, method in classMethods do
			markdownFile ..= h3(method.name)
			markdownFile ..= input(
				`> {className}:{method.name}({getReadableParamList(method)}) -> {getReadableReturnsList(method)}`
			)

			if method.desc then
				markdownFile ..= newline()
				markdownFile ..= input(method.desc)
			end
		end
	else
		markdownFile ..= input(`The {className} instance has no set methods!`)
	end

	markdownFile ..= newline()

	markdownFile ..= comment(`----- DOCUMENT FUNCTIONS ----- `)

	markdownFile ..= newline()

	markdownFile ..= h2(`Functions`)

	if sizeOfClassFunctions > 0 then
		for _, func in classFunctions do
			markdownFile ..= h3(func.name)
			markdownFile ..= input(
				`> {className}.{func.name}({getReadableParamList(func)}) -> {getReadableReturnsList(func)}`
			)

			if func.desc then
				markdownFile ..= newline()
				markdownFile ..= input(func.desc)
			end
		end
	else
		markdownFile ..= input(`The {className} instance has no set functions!`)
	end

	markdownFile ..= newline()

	return markdownFile
end

return Markdown