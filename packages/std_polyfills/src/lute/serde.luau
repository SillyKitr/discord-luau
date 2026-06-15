local json = require("@std/json")

local JSON_NULL = (json :: any).null

local function sanitizeNulls(value: any): any
	if value == JSON_NULL then
		return nil
	elseif type(value) == "table" then
		local internalKeys = {}

		for key, fieldValue in pairs(value) do
			if type(key) == "userdata" then
				table.insert(internalKeys, key)
			else
				value[key] = sanitizeNulls(fieldValue)
			end
		end

		for _, internalKey in internalKeys do
			value[internalKey] = nil
		end

		return value
	end

	return value
end

local serde = {}

function serde.encode(format: string, value: any, pretty: boolean?): string
	if format == "json" then
		return json.serialize(value, pretty)
	end

	error(`serde format '{format}' is not supported on Lute`)
end

function serde.decode(format: string, encoded: buffer | string): any
	if format == "json" then
		local raw =
			json.deserialize(if typeof(encoded) == "buffer" then buffer.tostring(encoded) else encoded :: string)

		return sanitizeNulls(raw)
	end

	error(`serde format '{format}' is not supported on Lute`)
end

function serde.compress(_format: string, _s: buffer | string, _level: number?): string
	error("Compression is not available on the Lute runtime")
end

function serde.decompress(_format: string, _s: buffer | string): string
	error("Compression is not available on the Lute runtime")
end

return serde
