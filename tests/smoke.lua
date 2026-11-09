local required_commands = {
	"Explore",
	"Lexplore",
	"EmbeddedBuild",
	"EmbeddedFlash",
	"EmbeddedMonitor",
	"EmbeddedDebug",
	"DiagnosticsReport",
	"ProjectTerminal",
}

for _, command in ipairs(required_commands) do
	assert(vim.fn.exists(":" .. command) == 2, command .. " command is unavailable")
end

assert(pcall(require, "core.embedded"), "embedded workflow module failed to load")
assert(pcall(require, "core.git"), "Git module failed to load")
assert(pcall(require, "core.diagnostics"), "diagnostics module failed to load")
assert(vim.fn.executable("git") == 1, "git is not available on PATH")
print("SMOKE_TEST_OK")
