--> Generate documentation for this project

local Moonwave = require("./util/generator/moonwave")
local Generator = require("./util/generator/generator")
local Markdown = require("./util/generator/markdown")

Generator.removeLegacyFiles()

local packageCommentJson = Moonwave.extractCommentsIntoJson()

for _, classDocumentation in packageCommentJson do
	local documentPath = Generator.writeClassName(classDocumentation.name)
	local documentContent = Markdown.generateMarkdownDocumentFor(classDocumentation)

	print(`Writing document '{classDocumentation.name}' to '{documentPath}', size: {string.len(documentContent)}`)

	Generator.writeClassContent(documentPath, documentContent)
end

return {}