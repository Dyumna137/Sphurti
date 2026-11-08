local required_commands = {
	"Explore",
	"Lexplore",
	"EmbeddedBuild",
	"EmbeddedFlash",
	"EmbeddedMonitor",
	"EmbeddedDebug",
}

for _, command in ipairs(required_commands) do
	assert(vim.fn.exists(":" .. command) == 2, command .. " command is unavailable")
end

assert(pcall(require, "core.embedded"), "embedded workflow module failed to load")
print("SMOKE_TEST_OK")
