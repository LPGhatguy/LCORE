local L, this = ...
this.title = "Table Extension Library"
this.version = "1.2"
this.status = "production"
this.desc = "Provides extensions for operating on tables."

local utable
local test

utable = {
	is_dictionary = function(self, source)
		for key in pairs(source) do
			if (type(key) ~= "number") then
				return true
			end
		end

		return false
	end,

	is_sequence = function(self, source)
		local last = 0

		for key in ipairs(source) do
			if (key ~= last + 1) then
				return false
			else
				last = key
			end
		end

		return (last ~= 0)
	end,

	array_data = function(self, target, ...)
		for key, value in ipairs(target) do
			target[key] = nil
		end

		for key, value in ipairs({...}) do
			target[key] = value
		end

		return target
	end,

	array_update = function(self, target, ...)
		for key, value in ipairs({...}) do
			target[key] = value
		end

		return target
	end,

	equal = function(self, first, second, no_reverse)
		for key, value in pairs(first) do
			if (second[key] ~= value) then
				return false, key
			end
		end

		if (not no_reverse) then
			return utable:equal(second, first, true)
		else
			return true
		end
	end,

	congruent = function(self, first, second, no_reverse)
		for key, value in pairs(first) do
			local value2 = second[key]

			if (type(value) == type(value2)) then
				if (type(value) == "table") then
					if (not utable:congruent(value, value2)) then
						return false, key
					end
				else
					if (value ~= value2) then
						return false, key
					end
				end
			else
				return false, key
			end
		end

		if (not no_reverse) then
			return utable:congruent(second, first, true)
		else
			return true
		end
	end,

	wrap = function(self, object, readonly)
		local interface = newproxy(true)
		local imeta = getmetatable(interface)

		imeta.__index = object

		if (not readonly) then
			imeta.__newindex = object
		end

		return interface
	end,

	copy = function(self, source, target)
		target = target or {}

		for key, value in pairs(source) do
			target[key] = value
		end

		return target
	end,

	deepcopy = function(self, source, target)
		target = target or {}

		for key, value in pairs(source) do
			local typeof = type(value)

			if (typeof == "table") then
				target[key] = utable:deepcopy(value)
			elseif (typeof == "userdata" and value.copy) then
				target[key] = value:copy()
			else
				target[key] = value
			end
		end

		return target
	end,

	merge = function(self, source, target)
		if (not target) then
			return nil
		end

		for key, value in pairs(source) do
			if (not target[key]) then
				target[key] = value
			end
		end

		return target
	end,

	copymerge = function(self, source, target)
		if (not target) then
			return nil
		end

		for key, value in pairs(source) do
			if (not target[key]) then
				local typeof = type(value)

				if (typeof == "table") then
					target[key] = utable:copy(value)
				elseif (typeof == "userdata" and value.copy) then
					target[key] = value:copy()
				else
					target[key] = value
				end
			end
		end

		return target
	end,

	deepcopymerge = function(self, source, target)
		if (not target) then
			return nil
		end

		for key, value in pairs(source) do
			if (not target[key]) then
				local typeof = type(value)

				if (typeof == "table") then
					target[key] = self:deepcopy(value)
				elseif (typeof == "userdata" and value.copy) then
					target[key] = value:copy()
				else
					target[key] = value
				end
			end
		end

		return target
	end,

	invert = function(self, source, target)
		target = target or {}

		for key, value in pairs(source) do
			target[value] = key
		end

		return target
	end,

	contains = function(self, source, value)
		for key, compare in pairs(source) do
			if (compare == value) then
				return true
			end
		end

		return false
	end
}

return utable