--> Run stylua to check for formatting errors

local process = require("@lune/process")

local CommandBuilder = require("./util/exec")

process.exit(CommandBuilder.new("stylua"):withArgs(process.args):withArg("."):withStdioStrategy("forward"):exec().code)
