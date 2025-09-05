--> lib: Builder pattern class to spawn child processes

local process = require("@lune/process")
local stdio = require("@lune/stdio")

local CommandBuilder = {}

export type CommandBuilder = typeof(setmetatable({} :: CommandBuilderFields, { __index = CommandBuilder }))
type CommandBuilderFields = {
	program: string,
	args: { string },
	stdioStrategy: IoStrategyMapping?,
}
export type StdioStrategy = "pipe" | "inherit" | "forward" | "none"
export type IoStrategyMapping = {
	stdin: StdioStrategy?,
	stdout: StdioStrategy?,
	stderr: StdioStrategy?,
}

local DEFAULT_STDIO_STRATEGY: IoStrategyMapping = {
	stdin = "pipe",
	stdout = "pipe",
	stderr = "pipe",
}
function CommandBuilder.new(program: string)
	return setmetatable(
		{
			program = program,
			args = {},
			stdioStrategy = nil,
		} :: CommandBuilderFields,
		{
			__index = CommandBuilder,
		}
	)
end

function CommandBuilder.withArg(self: CommandBuilder, arg: string): CommandBuilder
	table.insert(self.args, arg)
	return self
end

function CommandBuilder.withArgs(self: CommandBuilder, args: { string }): CommandBuilder
	for _, arg in args do
		self:withArg(arg)
	end

	return self
end

function CommandBuilder.withStdioStrategy(
	self: CommandBuilder,
	strategy: StdioStrategy | IoStrategyMapping
): CommandBuilder
	self.stdioStrategy = if typeof(strategy) == "string"
		then {
			stdout = strategy,
			stderr = strategy,
		}
		else strategy
	return self
end

local function intoSpawnOptionsStdioKind(strategy: StdioStrategy): process.ExecStdioKind
	if strategy == "pipe" then
		return "default"
	end

	if strategy == "inherit" then
		return "inherit"
	end

	if strategy == "forward" then
		return "forward"
	end

	if strategy == "none" then
		return "none"
	end

	error(`Non-strategy provided: {strategy}`)
end

function CommandBuilder.exec(self: CommandBuilder): process.ExecResult
	print("$", stdio.style("dim") .. self.program, table.concat(self.args, " ") .. stdio.style("reset"))

	local function translateIoStrategyMappings(mappings: IoStrategyMapping)
		local translatedMappings: process.ExecStdioOptions = {}
		for field: string, value in pairs(mappings) do
			translatedMappings[field] = intoSpawnOptionsStdioKind(value)
		end

		return translatedMappings
	end

	local child = process.exec(self.program, self.args, {
		shell = true,
		stdio = translateIoStrategyMappings(self.stdioStrategy or DEFAULT_STDIO_STRATEGY),
	})

	if not child.ok then
		print(`\n{stdio.color("red")}[luau-lsp]{stdio.color("reset")} Exited with code`, child.code)
	end

	return child
end

return CommandBuilder
