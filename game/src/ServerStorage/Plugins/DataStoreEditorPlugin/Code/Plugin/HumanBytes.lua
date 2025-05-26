-- Based off of: https://stackoverflow.com/a/63839503/2077120

local HumanBytes = {}

local METRIC_LABELS = { "B", "kB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB" }
local BINARY_LABELS = { "B", "KiB", "MiB", "GiB", "TiB", "PiB", "EiB", "ZiB", "Yib" }
local PRECISION_OFFSETS = { 0.5, 0.05, 0.005, 0.0005 }
local PRECISION_FORMATS = { "%s%i %s", "%s%.1f %s", "%s%.2f %s", "%s%.3f %s" }

function HumanBytes.Format(bytes: number, metric: boolean, precision: number)
	assert(type(bytes) == "number", "bytes must be a number")
	assert(type(metric) == "boolean", "metric must be a boolean")
	assert(type(precision) == "number", "precision must be a number")
	assert(
		precision >= 0 and precision <= 3 and math.floor(precision) == precision,
		"precision must be an integer in the range of [0, 3]"
	)

	local unitLabels = if metric then METRIC_LABELS else BINARY_LABELS
	local lastLabel = unitLabels[#unitLabels]
	local unitStep = if metric then 1000 else 1024
	local unitStepThreshold = unitStep - PRECISION_OFFSETS[precision + 1]

	local isNegative = bytes < 0
	if isNegative then
		bytes = math.abs(bytes)
	end

	local curUnit
	for _, unit in unitLabels do
		curUnit = unit
		if bytes < unitStepThreshold then
			break
		end
		if unit ~= lastLabel then
			bytes /= unitStep
		end
	end

	return string.format(PRECISION_FORMATS[precision], isNegative and "-" or "", bytes, curUnit)
end

return HumanBytes