local stdIo = require("@std/io")

local stdio = {}

function stdio.write(source: string)
	stdIo.write(source)
end

function stdio.prompt(message: string?): string
	if message then
		stdIo.write(message)
	end

	return stdIo.input() or ""
end

return stdio
