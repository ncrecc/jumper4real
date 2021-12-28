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
	tooltipScale = 0.75,
	showlogo = true,
	cheatcode = "",
	cheatcodetimer = 0
}

function menu.begin()
	menu.changeSubstate("title")
	audio.flushpauses()
	audio.play("34")
	menu.cheatcode = ""
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
	if menu.cheatcodetimer > 0 then menu.cheatcodetimer = menu.cheatcodetimer - 1
	else menu.cheatcodetimer = 0; menu.cheatcode = ""; end
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
	if key == "backspace" then
		menu.cheatcode = ""
		menu.cheatcodetimer = 0
	end
end

function menu.textinput(t)
	menu.cheatcode = menu.cheatcode .. t
	menu.cheatcodetimer = 100
	if menu.cheatcode == "rhubarb" then
		if menu.changedsettings then
			writetouniversalsettings()
		end
		menu.changeSubstate("rhubarbsettings")
		menu.cheatcodetimer = 0
		menu.cheatcode = ""
	elseif menu.cheatcode == "ransom" then
		if audio.activesong ~= "ransom in the sand" then
			audio.play("ransom in the sand", true)
		end
		menu.cheatcodetimer = 0
		menu.cheatcode = ""
	elseif menu.cheatcode == "boing" then
		if audio.activesong ~= "boing" then
			audio.play("boing", true)
		end
		menu.cheatcodetimer = 0
		menu.cheatcode = ""
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
		local r, g, b, a = nil, nil, nil, nil
		if menu.options[i].alpha ~= nil then
			r, g, b, a = love.graphics.getColor()
			love.graphics.setColor(r, g, b, menu.options[i].alpha)
		end
		love.graphics.print(optionname, menu.offsetfromleft, menu.offsetfromtop + (menu.linedistance * (i - 1)))
		if menu.options[i].alpha ~= nil then love.graphics.setColor(r, g, b, a) end
	end
	love.graphics.print(">", menu.offsetfromleft - 10, menu.offsetfromtop + (menu.linedistance * (menu.picker - 1)))
	love.graphics.printf(menu.options[menu.picker].tooltip, 0, love.graphics.getHeight() - 16, (love.graphics.getWidth() / menu.tooltipScale), "center", 0, menu.tooltipScale)
	if menu.showlogo then love.graphics.draw(graphics:load("J4R Logo 2x"), 172, 10) end
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
--menu.showlogo = ss.showlogo
	menu.picker = 1
	ss.onLoad()
end