local L, this = ...
this.title = "LOVE Platform Core"
this.version = "1.1"
this.status = "production"
this.desc = "Provides useful interfaces for integrating LCORE into LOVE."
this.todo = {
	"Make provide_loop work with love modules disabled."
}

if (not love) then
	L:error("Could not find 'love' to initialize love platform!")
	return
end

local lcore = L.lcore
local modules = lcore.platform.love
local event = lcore.service.event
local ref_core = lcore.platform.reference.core
local love_gfx = lcore.platform.love.graphics
local love_core

love_core = ref_core:derive {
	platform_name = "love",
	platform_version = love._version,

	graphics = modules.graphics,
	filesystem = modules.filesystem,

	hooks = {
		"load", "quit", "update", "draw",
		"errhand", "focus", "resize", "visible",
		"mousepressed", "mousereleased", "mousefocus",
		"keypressed", "keyreleased",
		"textinput", "threaderror",
		"gamepadaxis", "gamepadpressed", "gamepadreleased",
		"joystickadded", "joystickaxis", "joystickhat",
		"joystickpressed", "joystickreleased", "joystickremoved"
	},

	init = function(self)
		if (self.__provide_loop) then
			love.run = self.__run
		else
			for index, value in ipairs(self.hooks) do
				if (not love[value] or overwrite) then
					love[value] = function(...)
						event.global:fire(value, ...)
					end
				end
			end
		end
	end,

	quit = function(self)
		love.event.push("quit")
	end,

	--Implementation-specific fields:
	__provide_loop = true,

	__run = function()
		local global = event.global
		local dt = 0

		love.math.setRandomSeed(os.time())
		love.event.pump()

		if love.load then
			love.load(arg)
		end
		global:fire("load")

		love.timer.step()

		while (true) do
			love.event.pump()

			for e, a, b, c, d in love.event.poll() do
				if (e == "quit") then
					if (not love.quit or not love.quit()) then
						global:fire("quit")
						love.audio.stop()
						return
					end
				end
				
				love.handlers[e](a, b, c, d)
				global:fire(e, a, b, c, d)
			end

			love.timer.step()
			dt = love.timer.getDelta()

			if (love.update) then
				love.update(dt)
			end
			global:fire("update", dt)

			if (love.window.isCreated()) then
				love_gfx.clear()
				love_gfx.origin()

				if (love.draw) then
					love.draw()
				end
				global:fire("draw")

				love.graphics.present()
			end

			love.timer.sleep(0.001)
		end
	end
}

return love_core