local L, this = ...
this.title = "Mutable Function-Table"
this.version = "1.0"
this.status = "prototype"
this.desc = "Provides a lightweight mutable function type designed for method mixing"

local lcore = L.lcore
local oop = lcore.utility.oop
local utable = lcore.utility.table
local functable

functable = oop:class() {
	__functable = true,
	methods = {},

	_new = function(self, ...)
		setmetatable(self, getmetatable(self))

		self:append(...)
	end,

	call = function(self, ...)
		local count = #self.methods

		for index = 1, count - 1 do
			self.methods[index](...)
		end

		return self.methods[count](...)
	end,

	append = function(self, ...)
		local inverse = {}

		for index, method in ipairs(self.methods) do
			inverse[method] = index
		end

		for index, method in ipairs({...}) do
			if (not inverse[method]) then
				table.insert(self.methods, method)
			end
		end
	end
}

setmetatable(functable, {
	__call = functable.call
})

return functable