menu = {
	substateTemplate = "",
	options = {
		[1] = {
			name = "rhubarb",
			tooltip = "The fleshy, edible stalks of species and hybrids of Rheum in the family Polygonaceae.",
			action = function() end
		}
	},
	linedistance = 40,
	offsetfromleft = 192,
	offsetfromtop = 96,
	onUpdate = function() end,
	
	page = 1,
	numpages = 1,
	
	changedsettings = false,
	
	picker = 1,
	pickerHoldMoveDelayResetToLong = 30, --frames
	pickerHoldMoveDelayResetToShort = 7,
	pickerHoldMoveDelayCurrent = 0,
	pickerLongHoldPassed = false,
	tooltipScale = 0.75
}

function menu.begin()
	menu.changeSubstate("title")
	music:flushpauses()
	music:play("34")
end

function menu.update(dt)
	menu.onUpdate()
	--picker movement logic
	if menu.pickerHoldMoveDelayCurrent > 0 then
		menu.pickerHoldMoveDelayCurrent = menu.pickerHoldMoveDelayCurrent - 1
	end
	
	if menu.pickerHoldMoveDelayCurrent == 0 then
		if love.keyboard.isDown("down") then
			menu.movePicker("down")
			if not menu.pickerLongHoldPassed then
				menu.pickerHoldMoveDelayCurrent = menu.pickerHoldMoveDelayResetToLong
				menu.pickerLongHoldPassed = true
			else
				menu.pickerHoldMoveDelayCurrent = menu.pickerHoldMoveDelayResetToShort
			end
		elseif love.keyboard.isDown("up") then
			menu.movePicker("up")
			if not menu.pickerLongHoldPassed then
				menu.pickerHoldMoveDelayCurrent = menu.pickerHoldMoveDelayResetToLong
				menu.pickerLongHoldPassed = true
			else
				menu.pickerHoldMoveDelayCurrent = menu.pickerHoldMoveDelayResetToShort
			end
		end
	end
	if not love.keyboard.isDown("down") and not love.keyboard.isDown("up") then
		menu.pickerHoldMoveDelayCurrent = 0
		menu.pickerLongHoldPassed = false
	end
end

function menu.keypressed(key)
	if key == "return" then
		local option = menu.options[menu.picker]
		if option.vartoggle ~= nil then
			universalsettings[option.vartoggle] = not universalsettings[option.vartoggle]
			menu.changedsettings = true
		end
		option.action()
	end
end

function menu.draw()
	--love.graphics.print("welcome to hte menu Prass Enter to Play")
	for i=1, #menu.options do
		local optionname = menu.options[i].name
		if menu.options[i].vartoggle ~= nil then
			toggletext = "NO"
			if universalsettings[menu.options[i].vartoggle] then toggletext = "YES" end
			optionname = optionname .. toggletext
		end
		love.graphics.print(optionname, menu.offsetfromleft, menu.offsetfromtop + (menu.linedistance * (i - 1)))
	end
	love.graphics.print(">", menu.offsetfromleft - 10, menu.offsetfromtop + (menu.linedistance * (menu.picker - 1)))
	love.graphics.printf(menu.options[menu.picker].tooltip, 0, 496, (love.graphics.getWidth() / menu.tooltipScale), "center", 0, menu.tooltipScale)
end

function menu.stop()
	
end

function menu.movePicker(dir)
	if     dir == "up"   then menu.picker = menu.picker - 1
	elseif dir == "down" then menu.picker = menu.picker + 1 end
	if menu.picker < 1 then menu.picker = #menu.options end
	if menu.picker > #menu.options then menu.picker = 1 end
end

function menu.changeSubstate(substate)
	menu.substateTemplate = substate
	local ss = menu_substates[substate]
	menu.options = ss.options
	menu.linedistance = ss.linedistance
	menu.offsetfromleft = ss.offsetfromleft
	menu.offsetfromtop = ss.offsetfromtop
	menu.onUpdate = ss.onUpdate
	menu.picker = 1
	ss.onLoad()
end