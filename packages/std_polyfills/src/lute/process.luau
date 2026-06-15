local luteProcess = require("@std/process")
local luteSystem = require("@std/system")

local OS_MAP: { [string]: string } = {
	linux = "linux",
	macos = "macos",
	windows = "windows",
}

local ARCH_MAP: { [string]: string } = {
	x86_64 = "x86_64",
	aarch64 = "aarch64",
	arm64 = "aarch64",
}

local SIGNAL_MAP: { [string]: string } = {
	INT = "SIGINT",
	TERM = "SIGTERM",
}

local process = {}

process.os = OS_MAP[string.lower(luteSystem.os)] or string.lower(luteSystem.os)
process.arch = ARCH_MAP[string.lower(luteSystem.arch)] or string.lower(luteSystem.arch)
process.args = luteProcess.args
process.env = luteProcess.env

function process.cwd(): string
	return tostring(luteProcess.cwd())
end

function process.exit(code: number?)
	luteProcess.exit(code or 0)
end

function process.onSignal(signal: string, callback: () -> ())
	local resolvedSignal = SIGNAL_MAP[signal] or ("SIG" .. signal)

	luteProcess.onSignal(resolvedSignal, callback)
end

function process.run(exec: string, args: { string }?, opts: { cwd: string?, env: { [string]: string }? }?)
	local combinedArgs = { exec }

	if args then
		for _, arg in args do
			table.insert(combinedArgs, arg)
		end
	end

	local result = luteProcess.run(combinedArgs, opts :: any)

	return {
		ok = (result.exitcode or 0) == 0,
		code = result.exitcode or 0,
		stdout = result.stdout or "",
		stderr = result.stderr or "",
	}
end

return process
