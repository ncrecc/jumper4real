editor = {
	lmbtile = "t ",
	rmbtile = "  ",
	mmbtile = "t!",
	mbtilekeys = {"lmbtile", "rmbtile", "mmbtile"}, --purely for reference
	lastmbtouched = 1,
	currentpage = 1,
	pages = {}, --gets contents of editor_pages on each editor begin (except when returning from testing)
	currentsymbolmap = nil,
	maptileheight = 0,
	maptilewidth = 0,
	background = "#341160",
	addedheight = tilesize * 4,
	addedwidth = tilesize * 4,
	visiblesymbolmaps = 9,
	defaultsymbolmap = 5,
	viewallsymbolmaps = true,
	tilebaroffset_x = tilesize,
	tilebaroffset_y = tilesize,
	currentpath = "",
	currenttool = "pencil",
	originalmousepress = nil,
	eyedropperused = false,
	levelpackedfortesting = nil,
	returningfromgame = false,
	--tools is a *numeric* and thus specifically ordered table used to generate tool buttons in order.
	--toolbindings is a table that just matches keys to tool names, for keybindings. its order does not matter.
	--this kind of is writing everything twice but i'm not sure what would be a better solution if i want to be able to just do toolbindings[key] in keypressed instead of iterating something
	tools = {
		"pencil",
		"eyedropper",
		"rectangle",
		"fillrectangle",
		"fill"
	},
	toolbindings = {
		["c"] = "pencil",
		["e"] = "eyedropper",
		["r"] = "rectangle",
		["t"] = "fillrectangle",
		["f"] = "fill"
	},
	tooltipScale = 0.75,
	tooltip = nil,
	hoveredelement = nil
}
editor.textfields = {
	textfield:setup(256, 528, 160, 16, "saveload", "currentpath", "The level that should be saved to with Ctrl+S, or loaded with Ctrl+L.")
}
editor.focusedfield = nil

editor.buttons = {
	
}

local tooltips = { --thank you again to titku for writing these. i swear she's just always sitting in cocon waiting for me to almost write some stupid placeholders so she can make them less stupid lol -bert
	["pencil"] = "Pencil: Place a single tile at the spot you click on. Hotkey: C",
	["fill"] = "Fill: Fill a contiguous space with one type of tile. Hotkey: F",
	["eyedropper"] = "Eyedropper: Retrieve the tile at the spot you click on. Hotkey: E",
	["rectangle"] = "Rectangle: Efficiently draw a rectangular outline. Hotkey: R",
	["fillrectangle"] = "Filled rectangle: Efficiently draw a filled rectangle. Hotkey: T"
}

for i, v in ipairs(editor.tools) do
	table.insert(editor.buttons, button:setup(
		528 + (16 * ((i - 1) % 2)),
		16 + (16 * (math.floor((i - 1) / 2))),
		v,
		v,
		nil,
		function(self) editor.currenttool = v end,
		function(self)
			if editor.currenttool == v then
				self.depressed = true
			else self.depressed = false end
		end,
		tooltips[v]
	))
end

function editor.loadLevel(levelfilename)
	--[[for i=1, #game.loadedobjects do
		for ii=1, #game.loadedobjects[i] do
			game.loadedobjects[i][ii]:obliterate()
		end
	end]]
	--collectgarbage()
	levelfile = love.filesystem.read(levelfilename..".txt")
	if levelfile == nil then print "hey your level file ain't jack shit" end
	--print("levelling/" .. levelfilename .. ".txt")
	
	--print(levelfile)
	
	--initial parsing (e.g. sections)
	--witness kept saying i was "applying for the fucking iso" for not just using plain seperators instead of using the header/content thing
	local phase = nil
	local subphase = nil
	
	levelfile = correctnewlines(levelfile)
	levelfile = split(levelfile, "\n")
		
	local newsymbolmaps = {}
	local newexits = {}
	local newmusic = ""
	local newoptions = {}
	local newbackground = ""
	local y_tiled = 0
	local maplength = nil
	local symbolmapisempty = true
	
	for i, row in ipairs(levelfile) do
		local justsetphase = false
		if string.sub(row, 1, 3) == "===" and string.sub(row, -3, -1) == "===" then
			if phase == "MAP" and symbolmapisempty then
				print("uh oh, layer " .. subphase .. " was empty")
				newsymbolmaps[subphase].isempty = true
			end
			local phasedata = split(string.sub(row, 4, -4), ":")
			phase, subphase = phasedata[1], phasedata[2]
			if tonumber(subphase) ~= nil then subphase = tonumber(subphase) end
			y_tiled = 0
			justsetphase = true
			symbolmapisempty = true
		end
		--writes padding the beginning of each non-header row with | fixes the problem of === in user input potentially screwing things up. here adding | is optional to ensure... trivial backward-compatibility
		if string.sub(row, 1, 1) == "|" then row = string.sub(row, 2, -1) end
		if not justsetphase then
			if phase == "MAP" then
				if subphase == nil then subphase = 1 end
				if newsymbolmaps[subphase] == nil then newsymbolmaps[subphase] = {} end
				
				if maplength == nil then maplength = #row
				elseif maplength ~= #row then print("mate this row length is inconsistent... subphase: " .. subphase .. ", map length: " .. maplength .. " row length: " .. #row .. ", row (following line):\n" .. row .. "|end") end
				
				--map parsing
				y_tiled = y_tiled + 1
				
				local splitrow = nwidesplit(row, "", 2)
				if symbolmapisempty then
					for ii=1, #splitrow do
						if splitrow[ii] ~= "  " then
							symbolmapisempty = false
							break
						end
					end
				end
				table.insert(newsymbolmaps[subphase], splitrow)
			elseif phase == "EXITS" then
				table.insert(newexits, row)
			elseif phase == "MUSIC" then
				newmusic = row
			elseif phase == "OPTIONS" then
				table.insert(newoptions, row)
			elseif phase == "BACKGROUND" then
				newbackground = row
			end
		end
	end
	
	if newbackground == "" then newbackground = editor.background end
	return newsymbolmaps, newexits, newmusic, newoptions, newbackground
end

function editor.packLevel()
	levelfile = ""
	for i=1, #editor.symbolmaps do
		if not editor.symbolmaps[i].isempty then
			levelfile = levelfile .. "===MAP:" .. i .. "===\n"
			for ii=1, #editor.symbolmaps[i] do
				levelfile = levelfile .. "|"
				for iii=1, #editor.symbolmaps[i][ii] do
					levelfile = levelfile .. editor.symbolmaps[i][ii][iii]
				end
				levelfile = levelfile .. "\n"
			end
		end
	end
	levelfile = levelfile .. "===EXITS===\n"
	for i=1, #editor.exits do
		if editor.exits[i] ~= "" then levelfile = levelfile .. "|" .. editor.exits[i] .. "\n" end
	end
	levelfile = levelfile .. "===MUSIC===\n" .. "|" .. editor.music .. "\n"
	levelfile = levelfile .. "===OPTIONS===\n"
	--print("there's options")
	--print(#editor.options)
	for i=1, #editor.options do
		if editor.options[i] ~= "" then levelfile = levelfile .. "|" .. editor.options[i] .. "\n" end
	end
	return levelfile
end

editor.symbolmaps, editor.exits, editor.music, editor.options, editor.background = editor.loadLevel("defaultlevel")



function editor.makeEmptySymbolMap(w, h)
	local newmap = {}
	for i=1, h do
		local newrow = {}
		for ii=1, w do
			newrow[ii] = "  "
		end
		newmap[i] = newrow
	end
	newmap.isempty = true
	return newmap
end

function editor.handleLoadedLevel()
	local firstnonemptysymbolmap = nil
	local emptysymbolmaps = {}
	for i=1, editor.visiblesymbolmaps do
		if not editor.symbolmaps[i] then
			table.insert(emptysymbolmaps, i)
		elseif editor.symbolmaps[i] and not editor.symbolmaps[i].isempty then
			if not firstnonemptysymbolmap then firstnonemptysymbolmap = i end
			if editor.maptileheight < #editor.symbolmaps[i] then editor.maptileheight = #editor.symbolmaps[i] end
			if editor.symbolmaps[i][1] and editor.maptilewidth < #editor.symbolmaps[i][1] then editor.maptilewidth = #editor.symbolmaps[i][1] end
		end
	end
	print("detected maptilewidth: " .. editor.maptilewidth)
	print("detected maptileheight: " .. editor.maptileheight)
	for i=1, #emptysymbolmaps do
		editor.symbolmaps[emptysymbolmaps[i]] = editor.makeEmptySymbolMap(editor.maptilewidth, editor.maptileheight)
	end
	
	if firstnonemptysymbolmap == nil then firstnonemptysymbolmap = 1; print("all symbol maps were empty!"); end
	
	editor.currentsymbolmap = editor.defaultsymbolmap
	editor.symbolmap = editor.symbolmaps[editor.currentsymbolmap]
end

editor.handleLoadedLevel()

local numberquads = {}

for i=1, 9 do
	numberquads[i] = love.graphics.newQuad(i * 16, 0, 16, 16, graphics.load("ui/bignumbers"))
end

for i=1, editor.visiblesymbolmaps do
	if not editor.symbolmaps[i] then
		editor.symbolmaps[i] = editor.makeEmptySymbolMap(editor.maptilewidth, editor.maptileheight)
	end
	table.insert(editor.buttons, button:setup(
		528 + (16 * ((i - 1) % 3)),
		528 + (16 * (math.floor((i - 1) / 3))),
		"layer" .. i,
		"bignumbers",
		numberquads[i],
		function(self) editor.currentsymbolmap = i end,
		function(self)
			if editor.symbolmaps[i].isempty then
				self.iconrgba[4] = 0.5
			else
				self.iconrgba[4] = 1
			end
			if editor.currentsymbolmap == i then
				self.depressed = true
			else self.depressed = false end
		end,
		"Click to make Layer " .. i .. " the active layer."
	))
end

table.insert(editor.buttons, button:setup(
	512,
	512,
	"eyes",
	"eyes",
	nil,
	function(self) editor.viewallsymbolmaps = not editor.viewallsymbolmaps end,
	function(self)
		if editor.viewallsymbolmaps then
			self.depressed = true
		else self.depressed = false end
	end,
	"Click to toggle between viewing all layers of the map, or just the active layer."
))

function editor.begin()
	if not editor.returningfromgame then for k,v in pairs(editor_pages) do editor.pages[k] = v end end
	love.window.updateMode(512 + editor.addedwidth, 512 + editor.addedheight)
	if not editor.returningfromgame then audio.playsong("groove") end
	editor.returningfromgame = false
	editor.levelpackedfortesting = nil
end

function editor.checkemptymap()
	local thismapempty = true
	for y_tiled=1, #editor.symbolmap do
		for x_tiled=1, #editor.symbolmap[y_tiled] do
			if editor.symbolmap[y_tiled][x_tiled] ~= "  " then
				thismapempty = false
				break
			end
		end
	end
	if thismapempty then editor.symbolmap.isempty = true
	else editor.symbolmap.isempty = false end
end

function editor.update(dt)
	editor.symbolmap = editor.symbolmaps[editor.currentsymbolmap]
	editor.hoveredelement = nil
	editor.tooltip = nil
	local xpos, ypos = love.mouse.getPosition()
	if ypos < 512 and xpos < 512 then
		local xpos_tiled = 1 + math.floor(xpos / tilesize)
		local ypos_tiled = 1 + math.floor(ypos / tilesize)
		local mousedtile = editor.symbolmap[ypos_tiled][xpos_tiled]
		if love.mouse.isDown(1, 2, 3) then
			
			local tile = nil
			if love.mouse.isDown(1) then tile = editor.lmbtile
			elseif love.mouse.isDown(2) then tile = editor.rmbtile
			elseif love.mouse.isDown(3) then tile = editor.mmbtile
			else tile = editor.lmbtile end
			
			
			
			if editor.currenttool == "pencil" then
				editor.symbolmap[ypos_tiled][xpos_tiled] = tile
				if tile ~= "  " then editor.symbolmap.isempty = false
				else editor.checkemptymap() end
			
			
			elseif editor.currenttool == "fill" then
				local step = 0
				local replacetile = mousedtile
				if tile ~= replacetile then
					editor.symbolmap[ypos_tiled][xpos_tiled] = "fill"
					while step < 1000 do
						local nofillsdone = true
						for y_tiled=1, #editor.symbolmap do
							for x_tiled=1, #editor.symbolmap[y_tiled] do
								if editor.symbolmap[y_tiled][x_tiled] == replacetile then
									if
										(y_tiled > 1 and editor.symbolmap[y_tiled - 1][x_tiled] == "fill") or
										(y_tiled < #editor.symbolmap[y_tiled] and editor.symbolmap[y_tiled + 1][x_tiled] == "fill") or
										(x_tiled > 1 and editor.symbolmap[y_tiled][x_tiled - 1] == "fill") or
										(x_tiled < #editor.symbolmap[x_tiled] and editor.symbolmap[y_tiled][x_tiled + 1] == "fill")
									then
										editor.symbolmap[y_tiled][x_tiled] = "fill"
										nofillsdone = false
									end
								end
							end
						end
						if nofillsdone then break end
						step = step + 1
					end
					if step == 1000 then print("fill went on too long") end
					for y_tiled=1, #editor.symbolmap do
						for x_tiled=1, #editor.symbolmap[y_tiled] do
							if editor.symbolmap[y_tiled][x_tiled] == "fill" then
								editor.symbolmap[y_tiled][x_tiled] = tile
								if tile ~= "  " then editor.symbolmap.isempty = false
								else editor.checkemptymap() end
							end
						end
					end
				end
			end
		end
		if editor.currenttool == "eyedropper" then
			editor.tooltip = levelsymbols[mousedtile].tooltip
			if love.mouse.isDown(1, 2, 3) then editor.eyedropperused = true end
			if love.mouse.isDown(1) then editor.lmbtile = mousedtile
			elseif love.mouse.isDown(2) then editor.rmbtile = mousedtile
			elseif love.mouse.isDown(3) then editor.mmbtile = mousedtile end
		end
	else
		local xpos_tiled_fortilebar = 1 + math.floor((xpos - editor.tilebaroffset_x) / tilesize)
		local ypos_tiled_fortilebar = 1 + math.floor((ypos - 512 - editor.tilebaroffset_y) / tilesize)
		
		if editor.pages[editor.currentpage][ypos_tiled_fortilebar] ~= nil then
			if editor.pages[editor.currentpage][ypos_tiled_fortilebar][xpos_tiled_fortilebar] ~= nil then
				local symbol = editor.pages[editor.currentpage][ypos_tiled_fortilebar][xpos_tiled_fortilebar]
				editor.tooltip = levelsymbols[symbol].tooltip
				if love.mouse.isDown(1) then editor.lmbtile = symbol end
				if love.mouse.isDown(2) then editor.rmbtile = symbol end
				if love.mouse.isDown(3) then editor.mmbtile = symbol end
			end
		end
	end
	for i=1, #editor.buttons do
		local button = editor.buttons[i]
		if button.onUpdate then
			button:onUpdate()
		end
		if xpos >= (button.x) and xpos <= (button.x + button.width) and
		   ypos >= (button.y) and ypos <= (button.y + button.height) then
			editor.hoveredelement = button
			editor.tooltip = button.tooltip
		end
	end
	for i=1, #editor.textfields do
		local field = editor.textfields[i]
		if xpos >= (field.x) and xpos <= (field.x + field.width) and
		   ypos >= (field.y) and ypos <= (field.y + field.height) then
			editor.tooltip = field.tooltip
		end
	end
end

function editor.keypressed(key)
	if key == "escape" then
		statemachine.setstate("menu")
		menu.picker = 3
	end
	if editor.focusedfield == nil then
		if (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) and key == "s" then
			local levelfile = editor.packLevel()
			--love.filesystem.write("boink.txt",levelfile)
			local pathuptolevel = ""
			local pathuptoleveltemp = split(editor.currentpath, "/")
			for i=1, #pathuptoleveltemp - 1 do
				pathuptolevel = pathuptolevel .. pathuptoleveltemp[i]
				if i ~= #pathuptoleveltemp - 1 then pathuptolevel = pathuptolevel .. "/" end
			end
			if pathuptolevel == "" then
				print("saving, but since you didn't specify a folder this won't be playable...")
			else
				love.filesystem.createDirectory("ext_levelling/" .. pathuptolevel)
			end
			local success, message = love.filesystem.write("ext_levelling/" .. editor.currentpath .. ".txt",levelfile)
			if success then
				print("saved to " .. editor.currentpath .. ".txt!")
			else
				print("save failed. " .. message)
			end
		elseif (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) and key == "l" then
			if love.filesystem.getInfo("ext_levelling/"..editor.currentpath..".txt") == nil then print("mate you're not loading shit")
			else
				editor.symbolmaps, editor.exits, editor.music, editor.options, editor.background = editor.loadLevel("ext_levelling/"..editor.currentpath)
				editor.handleLoadedLevel()
				print("loaded level " .. editor.currentpath .. ".txt!")
			end
		elseif key == "tab" then
			editor.levelpackedfortesting = editor.packLevel()
			game.editormode = true
			game.map, game.tilemap, game.exits, game.currentsong, game.leveloptions, game.background = game.loadLevel(editor.levelpackedfortesting, true)
			statemachine.setstate("game")
		elseif key == "," or key == "." then
			--some tricky design here. these are the "rotate" keys, which rotate a tile, but there's also three mouse buttons available (inspired by rocks'n'diamonds, which didn't have rotations), so which do we rotate?
			--we assume the tile under the last moutse button the player touched. if that tile isn't rotatable, we check all mouse buttons for rotatable tiles in the order lmb, rmb, mmb.
			local rotatetile = nil
			local hasrotations = {false, false, false}
			for k,v in ipairs(editor.mbtilekeys) do
				hasrotations[k] = not not levelsymbols[editor[v]].rotations
			end
			
			local mbtotry = lastmbtouched
			if not hasrotations[mbtotry] then
				mbtotry = 1
				local mbstried = 0
				while not hasrotations[mbtotry] do
					mbstried = mbstried + 1
					mbtotry = ((mbtotry + 1) % 3) + 1 --see if another mouse button has a rotateable tile
					if mbstried >= 3 then break end
				end
			end
			
			rotatetile = editor.mbtilekeys[mbtotry] or "lmbtile"
			
			local rotations = levelsymbols[editor[rotatetile]].rotations
			if rotations then
				if key == "," and rotations[1] then
					for rownum,row in ipairs(editor.pages[editor.currentpage]) do
						for k,symbol in ipairs(row) do
							if symbol == editor[rotatetile] then
								editor.pages[editor.currentpage][rownum][k] = rotations[1]
							end
						end
					end
					editor[rotatetile] = rotations[1]
				elseif key == "." and rotations[2] then
					for rownum,row in ipairs(editor.pages[editor.currentpage]) do
						for k,symbol in ipairs(row) do
							if symbol == editor[rotatetile] then
								editor.pages[editor.currentpage][rownum][k] = rotations[2]
							end
						end
					end
					editor[rotatetile] = rotations[2]
				end
			end
		elseif editor.toolbindings[key] ~= nil then
			editor.currenttool = editor.toolbindings[key]
		elseif tonumber(key) ~= nil then
			local numberkey = tonumber(key)
			if(numberkey > 0 and numberkey < 10) then
				editor.currentsymbolmap = numberkey
			end
		end
	else
		if key == "backspace" then
			local field = editor.focusedfield
			editor[field.textsource] = string.sub(editor[field.textsource], 1, -2)
		end
	end
end

function editor.mousepressed(x, y, button)
	if editor.originalmousepress == nil then editor.originalmousepress = {["x"] = x, ["y"] = y} end
	if editor.focusedfield ~= nil then editor.focusedfield.focus = false end
	editor.focusedfield = nil
	love.keyboard.setKeyRepeat(false)
	if x > 512 or y > 512 then
		if button == 1 then
			for i=1, #editor.textfields do
				local field = editor.textfields[i]
				if x >= (field.x) and x <= (field.x + field.width) and
				   y >= (field.y) and y <= (field.y + field.height) then
					editor.focusedfield = field
					field.focus = true
					love.keyboard.setKeyRepeat(true)
					break
				end
			end
			for i=1, #editor.buttons do
				local button = editor.buttons[i]
				if x >= (button.x) and x <= (button.x + button.width) and
				   y >= (button.y) and y <= (button.y + button.height) then
					button:action()
					break
				end
			end
		end
	end
	if editor.focusedfield == nil then
		editor.lastmbtouched = button
	end
end

function editor.mousereleased(x, y, button)
	if x < 512 and y < 512 then
		if editor.eyedropperused and editor.currenttool == "eyedropper" and not love.mouse.isDown(1, 2, 3) then
			editor.currenttool = "pencil"
		end
	end
	if not love.mouse.isDown(1, 2, 3) then
		if(editor.currenttool == "rectangle" or editor.currenttool == "fillrectangle") then
			for y_tiled=1, #editor.symbolmap do
				for x_tiled=1, #editor.symbolmap[y_tiled] do
					local mousex, mousey = love.mouse.getPosition()
					local mousex_tiled = 1 + math.floor(mousex / tilesize)
					local origmousex_tiled = 1 + math.floor(editor.originalmousepress.x / tilesize)
					local mousey_tiled = 1 + math.floor(mousey / tilesize)
					local origmousey_tiled = 1 + math.floor(editor.originalmousepress.y / tilesize)
					local rectcondition = true
					if editor.currenttool == "rectangle" then rectcondition = (
						x_tiled == mousex_tiled or
						x_tiled == origmousex_tiled or
						y_tiled == mousey_tiled or
						y_tiled == origmousey_tiled
					); end
					
					if (rectcondition)
						and not
					((x_tiled < mousex_tiled and x_tiled < origmousex_tiled) or --mouse sex
						(x_tiled > mousex_tiled and x_tiled > origmousex_tiled) or
						(y_tiled < mousey_tiled and y_tiled < origmousey_tiled) or
						(y_tiled > mousey_tiled and y_tiled > origmousey_tiled))
					then
						local tile = nil
						if button == 1 then tile = editor.lmbtile
						elseif button == 2 then tile = editor.rmbtile
						elseif button == 3 then tile = editor.mmbtile
						else tile = editor.lmbtile end
						editor.symbolmap[y_tiled][x_tiled] = tile
						if tile ~= "  " then editor.symbolmap.isempty = false
						else editor.checkemptymap() end
					end
				end
			end
		end
		editor.eyedropperused = false
		editor.originalmousepress = nil
	end
end

function editor.textinput(t)
	if editor.focusedfield ~= nil then
		local field = editor.focusedfield
		editor[field.textsource] = editor[field.textsource] .. t
	end
end

function editor.drawSymbol(realsymbol, x, y)
	symbol = levelsymbols[realsymbol]
	if symbol == nil then error("\"" .. tostring(realsymbol) .. "\" isn't a symbol") end
	for i=1, #symbol.tiles do
		--make this less typing to reference later
		local tilename = symbol.tiles[i]
		--now we're actually using the tile as a key for the "tiles" array from tiles.lua, there was actually a redundant for loop here that couldn't have iterated through anything that i caught by commentating this
		local tile = tiles[tilename]
		--the way gfxoverride works is that if it exists, it's a table, and the game draws each graphic name in order (there can of course be just one entry in the table). if it doesn't exist, then the game just looks for the name of the tile as the graphic name
		if tile.gfxoverride then
			for ii=1, #tile.gfxoverride do
				love.graphics.draw(graphics.load(tile.gfxoverride[ii]), x + tile.gfxoverrideoffsets[ii][1], y + tile.gfxoverrideoffsets[ii][2])
			end
		else
			love.graphics.draw(graphics.load(tilename), x + tile.gfxoffsets[1], y + tile.gfxoffsets[2])
		end
	end
	
	for i=1, #symbol.objects do
		local objectname = symbol.objects[i]
		local options = {}
		local temp = split(objectname, ";")
		if #temp >  1 then
			objectname = temp[1]
			temp = split(temp[2], "|")
			for i=1, #temp do
				table.insert(options, temp[i])
			end
		end
		local object = objects[objectname]
		local graphictodraw = nil
		if object.editorimg ~= nil then
			graphictodraw = object.editorimg(options)
			love.graphics.draw(graphictodraw, x, y)
		elseif object.editordraw ~= nil then
			object.editordraw(x, y, options)
		else
			graphictodraw = graphics.load(objectname)
			love.graphics.draw(graphictodraw, x, y)
		end
	end
end

function editor.draw()
	local r, g, b, a = love.graphics.getColor()
	love.graphics.setColor(hextocolor(editor.background))
	love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	love.graphics.setColor(0.2, 0.2, 0.2)
	love.graphics.rectangle("fill", 0, 512, 512 + editor.addedwidth, 512)
	love.graphics.rectangle("fill", 512, 0, editor.addedwidth, 512)
	love.graphics.setColor(r, g, b, a)
	local symbolmapstodraw
	if editor.viewallsymbolmaps then symbolmapstodraw = editor.symbolmaps
	else symbolmapstodraw = {editor.symbolmap} end
	for _, symbolmap in ipairs(symbolmapstodraw) do
		for y_tiled=1, #symbolmap do
			--for each entry of the row
			for x_tiled=1, #symbolmap[y_tiled] do
				editor.drawSymbol(symbolmap[y_tiled][x_tiled], (x_tiled - 1) * tilesize, (y_tiled - 1) * tilesize)
				if love.mouse.isDown(1, 2, 3) and editor.originalmousepress ~= nil and (editor.currenttool == "rectangle" or editor.currenttool == "fillrectangle") then
					local mousex, mousey = love.mouse.getPosition()
					local mousex_tiled = 1 + math.floor(mousex / tilesize)
					local origmousex_tiled = 1 + math.floor(editor.originalmousepress.x / tilesize)
					local mousey_tiled = 1 + math.floor(mousey / tilesize)
					local origmousey_tiled = 1 + math.floor(editor.originalmousepress.y / tilesize)
					local rectcondition = true
					if editor.currenttool == "rectangle" then rectcondition = (
						x_tiled == mousex_tiled or
						x_tiled == origmousex_tiled or
						y_tiled == mousey_tiled or
						y_tiled == origmousey_tiled
					); end
					
					if (rectcondition)
						and not
					((x_tiled < mousex_tiled and x_tiled < origmousex_tiled) or
						(x_tiled > mousex_tiled and x_tiled > origmousex_tiled) or
						(y_tiled < mousey_tiled and y_tiled < origmousey_tiled) or
						(y_tiled > mousey_tiled and y_tiled > origmousey_tiled))
					then
						love.graphics.setColor(1, 1, 0, 0.5)
						local tile = nil
						if love.mouse.isDown(1) then tile = editor.lmbtile
						elseif love.mouse.isDown(2) then tile = editor.rmbtile
						elseif love.mouse.isDown(3) then tile = editor.mmbtile
						else tile = editor.lmbtile end
						if tile == "  " then
							love.graphics.setColor(1, 1, 0, 0.1)
							love.graphics.rectangle("fill", (x_tiled - 1) * tilesize, (y_tiled - 1) * tilesize, tilesize, tilesize)
						else
							editor.drawSymbol(tile, (x_tiled - 1) * tilesize, (y_tiled - 1) * tilesize)
						end
						love.graphics.setColor(r, g, b, a)
					end
				end
			end
		end
	end
	for i=1, #editor.pages[editor.currentpage] do
		for ii=1, #editor.pages[editor.currentpage][i] do
			local symbol = editor.pages[editor.currentpage][i][ii]
			if symbol == "  " then
				love.graphics.draw(graphics.load("ui/eraser"), ((ii - 1) * tilesize) + editor.tilebaroffset_x, ((i - 1) * tilesize) + editor.tilebaroffset_y + 512)
			else
				editor.drawSymbol(symbol, ((ii - 1) * tilesize) + editor.tilebaroffset_x, ((i - 1) * tilesize) + editor.tilebaroffset_y + 512)
			end
			local selectgraphics = {}
			if symbol == editor.lmbtile then table.insert(selectgraphics, "select_lmb") end
			if symbol == editor.rmbtile then table.insert(selectgraphics, "select_rmb") end
			if symbol == editor.mmbtile then table.insert(selectgraphics, "select_mmb") end
			for iii=1, #selectgraphics do love.graphics.draw(graphics.load(selectgraphics[iii]), ((ii - 1) * tilesize) + editor.tilebaroffset_x, ((i - 1) * tilesize) + editor.tilebaroffset_y + 512) end
		end
	end
	for i=1, #editor.textfields do
		editor.textfields[i]:draw()
	end
	for i=1, #editor.buttons do
		editor.buttons[i]:draw()
	end
	if editor.tooltip ~= nil then
		printAsTooltip(editor.tooltip, editor.tooltipScale)
	end
end

function editor.stop()
	love.window.updateMode(512, 512)
	love.keyboard.setKeyRepeat(false)
end