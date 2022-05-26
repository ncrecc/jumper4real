writer = {}
writer.code = [[
require("love.filesystem")
love.filesystem.write(...)
]]
writer.thread = love.thread.newThread(writer.code)
writeto = function(mode)
	local dowrite = function(...) --holy shit it's Do Write by Cabinet Voltage from their album Micro-Phones
		if writer.thread:isRunning() then
			print("asking the write thread to write again when it's not done with the previous write, yeesh!")
			writer.thread:wait()
		end
		writer.thread:start(...)
	end
	dowrite(writer.modes[mode]())
end
writer.modes = {
	settings = function()
		--[=[
		local towrite = ""
		for i=1, #settingsargs do
			towrite = towrite .. booltostr(settings[settingsargs[i]]) .. "\n"
		end
		]=]
		local towrite = {}
		for i=1, #settingsargs do
			towrite[#towrite + 1] = booltostr(settings[settingsargs[i]])
		end
		return "settings.txt", table.concat(towrite, "\n")
	end,
	ogmoskin = function()
		return "ogmoskin.txt", game.ogmoskin
	end,
	unlockedcheats = function()
		local towrite = {}
		for i=1, #cheat.unlockedcheats do
			towrite[#towrite + 1] = cheat.unlockedcheats[i]
		end
		return "unlockedcheats.txt", table.concat(towrite, "\n")
	end,
	activecheats = function()
		local towrite = {}
		for i=1, #cheat.activecheats do
			towrite[#towrite + 1] = cheat.activecheats[i]
		end
		return "activecheats.txt", table.concat(towrite, "\n")
	end,
	controls = function()
		local towrite = ""
		local phase = nil
		for k,v in pairs(controls) do
			towrite = towrite .. "===" .. k .. "===\n|" .. v .. "\n"
		end
		return "controls.txt", towrite
	end
}