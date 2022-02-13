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
	cheatcodetimer = 0,
	nifty = false,
	niftyimg = {},
	lastmousepos = {x = nil, y = nil},
	mousepos = {x = 0, y = 0},
	cancheat = true
}

function menu.begin()
	menu.changeSubstate("title")
	audio.flushpauses()
	audio.playsong("34")
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
	
	--oh god this entire part is just for a "scribble stuff on the menu" cheat
	if menu.nifty then
		local mouseisdown = love.mouse.isDown(1, 2, 3)
		menu.lastmousepos.x, menu.lastmousepos.y = menu.mousepos.x, menu.mousepos.y
		if not mouseisdown then menu.lastmousepos.x, menu.lastmousepos.y = nil, nil end
		menu.mousepos.x, menu.mousepos.y = love.mouse.getPosition()
		if mouseisdown then
			if (not (menu.lastmousepos.x and menu.lastmousepos.y)) or ((menu.lastmousepos.x == menu.mousepos.x) and (menu.lastmousepos.y == menu.mousepos.y)) then --we check if last mouse pos is nil *or* if it's the same as mouse pos, because in either case the "make a line" procedure is unnecessary and will error deu to either nil values or a division by zero
				local y = menu.mousepos.y
				local x = menu.mousepos.x
				if menu.niftyimg[y + 1] ~= nil and menu.niftyimg[y + 1][x + 1] ~= nil then
					menu.niftyimg[y + 1][x + 1] = true
				end
			else
				--make a line between current mouse pos and last mouse pos
				--this is probably really inefficient and terrible but i came up with it by myself (because i'm too lazy to look it up)
				local x1, y1 = menu.mousepos.x, menu.mousepos.y
				local x2, y2 = menu.lastmousepos.x, menu.lastmousepos.y
				
				local step_x = x1
				local step_y = y1
				
				local step_x_relative = 0
				local step_y_relative = 0
				
				local x2_relative = x2 - x1
				local y2_relative = y2 - y1
				
				local larger = math.abs(x2_relative)
				if math.abs(y2_relative) > larger then larger = math.abs(y2_relative) end
				
				local stepby_x = x2_relative / larger
				local stepby_y = y2_relative / larger
				
				local stepcount = 0
				
				while math.abs(step_x_relative) <= math.abs(x2_relative) and math.abs(step_y_relative) <= math.abs(y2_relative) do
					local step_y_rounded = math.floor(step_y + .5)
					local step_x_rounded = math.floor(step_x + .5)
					if menu.niftyimg[step_y_rounded + 1] ~= nil and menu.niftyimg[step_y_rounded + 1][step_x_rounded + 1] ~= nil then
						menu.niftyimg[step_y_rounded + 1][step_x_rounded + 1] = true
					end
					step_y = step_y + stepby_y
					step_x = step_x + stepby_x
					step_y_relative = step_y_relative + stepby_y
					step_x_relative = step_x_relative + stepby_x
				end
			end
		end
	end
end

function menu.keypressed(key)
	if key == "return" then
		local option = menu.options[menu.picker]
		if option.vartoggle ~= nil then
			settings[option.vartoggle] = not settings[option.vartoggle]
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
	if menu.cancheat then
		menu.cheatcode = menu.cheatcode .. t
		menu.cheatcodetimer = 100
		local didcheat = false
		if menu.cheatcode == "rhubarb" then
			if menu.changedsettings then
				writetosettings()
			end
			menu.changeSubstate("rhubarbsettings")
			didcheat = true
		elseif menu.cheatcode == "ransom" then
			if audio.activesong ~= "ransom in the sand" then
				audio.playsong("ransom in the sand", true)
			end
			didcheat = true
		elseif menu.cheatcode == "boing" then
			if audio.activesong ~= "boing" then
				audio.playsong("boing", true)
			end
			didcheat = true
		elseif menu.cheatcode == "clique" then
			game.cliquemode = true
			didcheat = true
		elseif menu.cheatcode == "nifty" then
			menu.nifty = true
			for y=1, love.graphics.getHeight() do
				menu.niftyimg[y] = {}
				for x=1, love.graphics.getWidth() do
					menu.niftyimg[y][x] = false
				end
			end
			didcheat = true
		elseif menu.cheatcode == "scroller1" then
			game.scrollmove = true
			didcheat = true
		elseif menu.cheatcode == "youreglue" then
			game.imrubber = not game.imrubber
			didcheat = true
		elseif menu.cheatcode == "agodami" then
			game.godmode = not game.godmode
			didcheat = true
		end
		
		if didcheat then
			menu.cheatcodetimer = 0
			menu.cheatcode = ""
			audio.playsfx("cheat")
		end
	end
end

function menu.draw()
	--love.graphics.print("welcome to hte menu Prass Enter to Play")
	local r, g, b, a = love.graphics.getColor()
	for i=1, #menu.options do
		local optionname = menu.options[i].name
		if menu.options[i].vartoggle ~= nil then
			toggletext = "NO"
			if settings[menu.options[i].vartoggle] then toggletext = "YES" end
			optionname = optionname .. toggletext
		end
		if menu.options[i].alpha ~= nil then
			love.graphics.setColor(r, g, b, menu.options[i].alpha)
		end
		love.graphics.print(optionname, menu.offsetfromleft, menu.offsetfromtop + (menu.linedistance * (i - 1)))
		if menu.options[i].alpha ~= nil then love.graphics.setColor(r, g, b, a) end
	end
	love.graphics.print(">", menu.offsetfromleft - 10, menu.offsetfromtop + (menu.linedistance * (menu.picker - 1)))
	printAsTooltip(menu.options[menu.picker].tooltip, menu.tooltipScale)
	if menu.showlogo then love.graphics.draw(graphics.load("J4R Logo 2x"), 172, 10) end
	if menu.nifty then
		love.graphics.setColor(1, 0, 1, 1)
		for y=1, love.graphics.getHeight() do
			if menu.niftyimg[y] then
				for x=1, love.graphics.getWidth() do
					if menu.niftyimg[y][x] then love.graphics.rectangle("fill", x - 1, y - 1, 1, 1) end
				end
			end
		end
		love.graphics.setColor(r, g, b, a)
	end
end

function menu.stop()
	menu.nifty = false
	menu.niftyimg = {}
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