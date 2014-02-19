--[[
#id graphics.ui.circle_shape
#title UI Circle Superclass
#status incomplete
#version 0.1

#desc The father of all circular UI elements
]]

local L = (...)
local oop = L:get("utility.oop")
local element = L:get("graphics.ui.element")
local circle_shape

circle_shape = oop:class(element)({
	r = 0,

	_new = function(self, new, x, y, r)
		new.x = x or 0
		new.y = y or 0
		new.r = r or 0

		return new
	end,

	contains = function(self, x, y)
		return ((x - self.x) ^ 2 + (y - self.y) ^ 2) < (self.r ^ 2)
	end
})

return circle_shape