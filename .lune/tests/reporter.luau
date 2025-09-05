--> lib: Extension to base frktest reporter for live status reporting

local stdio = require("@lune/stdio")

local frktest = require("../../lune_packages/frktest")
local Reporter = frktest.reporters.console_reporter

local watch = require("../util/channel")

local STYLE = table.freeze({
	suite = function(name: string)
		return `{stdio.style("bold")}{stdio.color("purple")}SUITE{stdio.style("reset")} {name}`
	end,

	report = function(name: string, state: "success" | "error" | "skip", elapsed: number)
		local state_color: stdio.Color = if state == "success"
			then "green"
			elseif state == "error" then "red"
			elseif state == "skip" then "yellow"
			else error("Invalid test state")
		return `    {stdio.style("bold")}{stdio.color(state_color)}{if state == "skip" then "SKIP" else "TEST"}{stdio.style(
			"reset"
		)} {name} [{stdio.style("dim")}{string.format("%.2fms", elapsed)}{stdio.style("reset")}]`
	end,
})

local ReporterExt = {}
function ReporterExt.init()
	frktest.test.on_suite_enter(function(suite)
		print(STYLE.suite(suite.name))
	end)

	frktest.test.on_suite_leave(function()
		stdio.write("\n")
	end)

	local send_ts, recv_ts = watch((nil :: any) :: number)

	frktest.test.on_test_enter(function()
		-- Send over some high precision timestamp when the test starts
		return send_ts(os.clock())
	end)

	frktest.test.on_test_leave(function(test)
		print(STYLE.report(
			test.name,
			if test.failed then "error" else "success",

			-- Await receival of the timestamp and convert the difference to ms
			(os.clock() - assert(recv_ts())) * 1000
		))
	end)

	frktest.test.on_test_skipped(function(test)
		print(STYLE.report(test.name, "skip", 0))
	end)

	Reporter.init()
end

return setmetatable(ReporterExt, { __index = Reporter })
