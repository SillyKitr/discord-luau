-- Lute has no calendar datetime API. Use os.time() (available via Luau's standard library).

local function isoFromTimestamp(timestamp: number): string
	return os.date("!%Y-%m-%dT%H:%M:%SZ", timestamp) :: string
end

local function parseIsoDate(isoDate: string): number
	local year, month, day, hour, minute, second = string.match(isoDate, "(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)")

	if not year then
		error(`Invalid ISO date: '{isoDate}'`)
	end

	-- os.time() treats its input table as LOCAL time, not UTC. Compute the UTC offset
	-- by comparing os.time() against the local interpretation of its own UTC components,
	-- then add the offset so the result is always a correct UTC Unix timestamp.
	local probe = os.time()
	local utcOffset = probe - os.time(os.date("!*t", probe) :: any)

	return os.time({
		year = tonumber(year) :: number,
		month = tonumber(month) :: number,
		day = tonumber(day) :: number,
		hour = tonumber(hour) :: number,
		min = tonumber(minute) :: number,
		sec = tonumber(second) :: number,
	}) + utcOffset
end

local function wrapTimestamp(timestamp: number)
	return {
		unixTimestamp = timestamp,
		unixTimestampMillis = timestamp * 1000,
		toIsoDate = function(_self)
			return isoFromTimestamp(timestamp)
		end,
	}
end

local datetime = {}

function datetime.now()
	return wrapTimestamp(os.time())
end

function datetime.fromUnixTimestamp(unixTimestamp: number)
	return wrapTimestamp(unixTimestamp)
end

function datetime.fromIsoDate(isoDate: string)
	return wrapTimestamp(parseIsoDate(isoDate))
end

return datetime
