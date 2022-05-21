local font = love.graphics.getFont()
menu = {
	width = 512,
	height = 512,
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
	
	changed = {},
	
	picker = nil,
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
	cancheat = true,
	logoname = "J4R Logo 2x",
	onLoad = function() end,
	stack = {},
	pickerstack = {},
	pagestack = {}, --i think in an ideal implementation, this would be redundant to pickerstack. and you'd just do modulo 7 stuff and assume anything past index 7 is special and the stacks don't need to be concerned with it
--	pagesstack = {}, --this is definitely stupid and only for visual purposes)
	multipage = false,
	pages = 1,
	page = 1,
	fulloptions = {},
	itemsperpage = 7,
	misctext = love.graphics.newText(font, ""),
}

function menu.begin()
	--[[
	menu.stackreset()
	menu.picker = nil
	menu.changeSubstate("title")
	]]
	audio.flushpauses()
	if not cheat.isactive("jumper4imaginary") then
		audio.playsong("34")
	else
		audio.playsong("trollful horns")
	end
	menu.cheatcode = ""
end

function menu.changelogo(logoname)
	if logoname ~= menu.logoname then
		menu.logoname = logoname
		graphics.load(menu.logoname)
		graphics.load(menu.logoname .. " blink")
		menu.blinktimer = nil
	end
end

function menu.update(dt)
	if menu.blinktimer and menu.blinktimer > 0 then menu.blinktimer = menu.blinktimer - 1 end
	if menu.blinktimer and menu.blinktimer <= 0 then menu.blinktimer = nil end
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
	if cheat.isactive("nifty") then
		local mouseisdown = love.mouse.isDown(1, 2, 3)
		menu.lastmousepos.x, menu.lastmousepos.y = menu.mousepos.x, menu.mousepos.y
		if not mouseisdown then menu.lastmousepos.x, menu.lastmousepos.y = nil, nil end
		menu.mousepos.x, menu.mousepos.y = love.mouse.getPosition()
		if mouseisdown then
			if (not (menu.lastmousepos.x and menu.lastmousepos.y)) or ((menu.lastmousepos.x == menu.mousepos.x) and (menu.lastmousepos.y == menu.mousepos.y)) then --we check if last mouse pos is nil *or* if it's the same as mouse pos, because in either case the "make a line" procedure is unnecessary and would error due to either nil values or a division by zero
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
		if option.vartoggle ~= nil then --this is hardcoded but could very easily be replaced with getname()
			settings[option.vartoggle] = not settings[option.vartoggle]
			menu.changed.settings = true
		end
		option.action()
	elseif key == "backspace" then
		menu.cheatcode = ""
		menu.cheatcodetimer = 0
	elseif key == "escape" then
		if #menu.stack == 1 then
			love.event.quit()
		else
			menu.back()
		end
    end
end

function menu.textinput(t)
	if menu.cancheat then
		menu.cheatcode = menu.cheatcode .. t
		menu.cheatcodetimer = 100
		local thischeat = cheat.get(menu.cheatcode)
		if thischeat then
			local cheatmenu_firstunlock = not next(cheat.unlockedcheats)
			menu.blinktimer = 8
			menu.cheatcodetimer = 0
			audio.playsfx("cheat")
			cheat.invoke(thischeat)
			if not thischeat.unlocked and not thischeat.hidden then
				print(menu.cheatcode .. " unlocked via typing!")
				thischeat.unlocked = true
				table.insert(cheat.unlockedcheats, menu.cheatcode)
				menu.changed.unlockedcheats = true
			end
			menu.cheatcode = ""
			menu.onCheat(cheatmenu_firstunlock)
		end
	end
end

function menu.draw()
	--love.graphics.print("welcome to hte menu Prass Enter to Play")
	local r, g, b, a = love.graphics.getColor()
	for i=1, #menu.options do
		local optionname
		if menu.options[i].getname then optionname = menu.options[i]:getname() end
		if not optionname then optionname = menu.options[i].name end
		if menu.options[i].vartoggle ~= nil then
			local toggletext = "NO"
			if settings[menu.options[i].vartoggle] then toggletext = "YES" end
			optionname = optionname .. toggletext
		end
		if menu.options[i].alpha ~= nil then
			love.graphics.setColor(r, g, b, menu.options[i].alpha)
		end
		love.graphics.print(optionname, menu.offsetfromleft, menu.offsetfromtop + (menu.linedistance * (i - 1)))
		if menu.options[i].alpha ~= nil then love.graphics.setColor(r, g, b, a) end
	end
	menu.onDraw()
	love.graphics.print(">", menu.offsetfromleft - 10, menu.offsetfromtop + (menu.linedistance * (menu.picker - 1)))
	printAsTooltip(menu.options[menu.picker].tooltip, menu.tooltipScale)
	if menu.showlogo then
		local imagetoshow
		if menu.blinktimer then imagetoshow = graphics.load(menu.logoname .. " blink") end
		if not imagetoshow then imagetoshow = graphics.load(menu.logoname) end
		love.graphics.draw(imagetoshow, math.floor((menu.width - imagetoshow:getWidth()) / 2), 10)
	end
	menu.misctext:setf(table.concat(menu.stack, " > "), menu.width, "left")
	love.graphics.draw(menu.misctext)
	menu.misctext:setf("v" .. version, menu.width, "left")
	love.graphics.draw(menu.misctext, menu.width - menu.misctext:getWidth(), menu.height - menu.misctext:getHeight())
	local cheatamt = 0
	if cheat.activecheats then cheatamt = #cheat.activecheats end
	if cheatamt > 0 or menu.alwaysshowcheatamt then
		menu.misctext:setf("cheats: " .. cheatamt, menu.width, "left")
		love.graphics.draw(menu.misctext, menu.width - menu.misctext:getWidth(), 0)
	end
	--love.graphics.print(table.concat(menu.pickerstack, " > "), 0, 16)
	if menu.pages > 1 then love.graphics.print("(" .. menu.page .. "/" .. menu.pages .. ")", 242, 72) end
	if cheat.isactive("nifty") then
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
	menu.handleWrites()
	menu.niftyimg = {}
end

function menu.movePicker(dir)
	if     dir == "up"   then menu.picker = menu.picker - 1
	elseif dir == "down" then menu.picker = menu.picker + 1 end
	if menu.picker < 1 then menu.picker = #menu.options end
	if menu.picker > #menu.options then menu.picker = 1 end
end

function menu.stackreset()
	menu.stack = {}
	menu.pickerstack = {}
end

function menu.back()
	--menul.stack (which contains substates) keeps the current substate in the stack, but menu.pickerstack and menu.pagestack don't keep the current picker position/page in the stack. not sure how it 1ended up like this. probably something to do with how stack pushes are triggered by changing substate.
	table.remove(menu.stack)
	menu.picker = menu.pickerstack[#menu.pickerstack]
	table.remove(menu.pickerstack)
	menu.page = menu.pagestack[#menu.pagestack]
	table.remove(menu.pagestack)
	menu.changeSubstate(menu.stack[#menu.stack], true)
end

function menu.refresh()
	menu.changeSubstate(menu.stack[#menu.stack], true, true)
end

function menu.appendBackOption(name, tooltip)
	menu.options[#menu.options + 1] = {
		name = name or "back",
		tooltip = tooltip or "return to previous screen",
		action = menu.back
	}
end

function menu.pageSetup()
	menu.options = {}
	local i = 0
	for ii = (7 * (menu.page - 1)) + 1, 7 * menu.page do
		i = i + 1
		menu.options[i] = menu.fulloptions[ii]
	end
	menu.appendChangePageOption("previous", -1, tern(menu.noback, 1, 2))
	menu.appendChangePageOption("next", 1, tern(menu.noback, 0, 1))
	if not menu.noback then
		menu.appendBackOption(menu.backname, menu.backtooltip)
	end
end

function menu.appendChangePageOption(kind, amt, offsetfrombottom)
	local newpage = menu.page + amt
	menu.options[#menu.options + 1] = {
		name = kind .. " page",
		tooltip = "go to the " .. kind .. " page",
		alpha = tern(newpage > 0 and newpage <= menu.pages, 1, 0.5),
		action = function()
			if newpage > 0 and newpage <= menu.pages then
				menu.page = newpage
				menu.pageSetup()
				menu.picker = #menu.options - offsetfrombottom
			end
		end
	}
end

function menu.handleWrites()
	for k,v in pairs(menu.changed) do
		if v then
			print(k .. " changed, writing")
			writeto[k]()
		end
	end
	menu.changed = {}
end

function menu.changeSubstate(substate, neutral, ignorewriting)
	if not ignorewriting then menu.handleWrites() end
	menu.fulloptions = {}
	menu.multipage = false
	menu.pages = 1
	if not neutral then
		table.insert(menu.stack, substate) --again, when a substate change triggers stack pushes, the NEW substate is pushed onto the substate stack, not the old one. this is contrary to how the pickerstack and pagestack work. some day it's going to turn out i'm actually just writing gibberish on the walls inside a padded cell
		table.insert(menu.pickerstack, menu.picker)
		table.insert(menu.pagestack, menu.page)
	end
	if not neutral then menu.picker = 1 end
	if not neutral then menu.page = 1 end
	menu.substateTemplate = substate
	local ss = menu_substates[substate]
	menu.options = table.copy(ss.options)
	menu.linedistance = ss.linedistance or 40
	menu.offsetfromleft = ss.offsetfromleft or 192
	menu.offsetfromtop = ss.offsetfromtop or 96
	menu.onUpdate = ss.onUpdate or function() end
	menu.onDraw = ss.onDraw or function() end
--menu.showlogo = ss.showlogo
	menu.onCheat = ss.onCheat or function() end
	menu.onLoad = ss.onLoad or function() end
	menu.onLoad()
	menu.noback = ss.noback
	menu.backname = ss.backname
	menu.backtooltip = ss.backtooltip
	menu.alwaysshowcheatamt = ss.alwaysshowcheatamt
	if #menu.options > menu.itemsperpage then
		menu.pages = math.ceil(#menu.options / menu.itemsperpage)
		menu.fulloptions = table.copy(menu.options)
		menu.multipage = true
		menu.pageSetup()
	elseif not ss.noback then
		menu.appendBackOption(ss.backname, ss.backtooltip)
	end
end