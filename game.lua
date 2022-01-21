game = {
	playeramt = 0,
	liveplayeramt = 0,
	loadedobjects = {},
	leveloptions = {},
	mapname = "",
	exits = {},
	currentlevelset = "",
	currentsong = "",
	map = {},
	tilemap = {}, --multiple tiles actually can go on each coordinate so each square here is represented by a table
	cliquemode = false,
	editormode = false,
	levelwidth = 512,
	levelheight = 512,
	ogmoskin = "ogmo",
	background = "#341160",
	paused = false,
	pausedformenu = false,
	fact = nil
}

function game.begin()
	if not game.editormode then
		game.map, game.tilemap, game.exits, game.currentsong, game.leveloptions, game.background = game.loadLevel(game.currentlevelset .. "/" .. game.mapname)
		audio.playsong(game.currentsong, false)
	end
end

function game.update(dt)
	if not game.paused then
		--[=[
		for i=1, #objectnamelist do
			if game.loadedobjects[objectnamelist[i]] ~= nil then
				for ii=1, #game.loadedobjects[objectnamelist[i]] do
					game.loadedobjects[objectnamelist[i]][ii]:update()
				end
			end
		end
		]=]
		for i=1, #game.loadedobjects do
			if game.loadedobjects[i] then --briefly after loading a level, all contents of game.loadedobjects are set to nil - game.loadedobjects = {} seems first to set contents to nil and then clear it very slightly later. calling garbage collection early doesn't help with this
				game.loadedobjects[i]:update()
			end
		end
		if game.liveplayeramt == 0 then
			print("all players are dead! :( reinitializing map")
			if not game.editormode then
				game.map, game.tilemap, game.exits, _, _, game.background = game.loadLevel(game.currentlevelset .. "/" .. game.mapname)
			else
				game.map, game.tilemap, game.exits, _, _, game.background = game.loadLevel(editor.levelpackedfortesting, true)
			end
		end
	end
end

function game.keypressed(key)
	for i=1, #game.loadedobjects do
		--if game.loadedobjects[i].keyreactions and game.loadedobjects[i].keyreactions[key] then
		if game.loadedobjects[i].keypressed then
			game.loadedobjects[i]:keypressed(key)
		end
	end
	if key == "escape" or (game.editormode and key == "tab") then
		if not game.editormode then
			statemachine.setstate("menu")
		else
			statemachine.setstate("editor")
		end
	end
	if key == "p" then
		game.paused = not game.paused
		game.pausedformenu = game.paused
		audio.playsfx("pause")
		if game.pausedformenu then
			game.fact = facts[love.math.random(1, #facts)]
			if audio.activesong ~= nil then
				song = audio.loadedsongs[audio.activesong]
			end
			if audio.activesongoneshot then
				song:setFilter(audio.lowpass)
			else
				if song.intro ~= nil then song.intro:setFilter(audio.lowpass) end
				song.loop:setFilter(audio.lowpass)
			end
		else
			if audio.activesong ~= nil then
				song = audio.loadedsongs[audio.activesong]
				if audio.activesongoneshot then
					song:setFilter()
				else
					if song.intro ~= nil then song.intro:setFilter() end
					song.loop:setFilter()
				end
			end
		end
	end
	--[[
   if key == "rctrl" then
      debug.debug()
   end
   ]]--
end

function game.draw()
	local r, g, b, a = love.graphics.getColor()
	love.graphics.setColor(hextocolor(game.background))
	love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	love.graphics.setColor(r, g, b, a)
	--ok i'll try to break this down step-by-step for future me's convenience
	--game.tilemap is like map but instead of containing just symbols it just contains the tile names the symbols would point to
	--for each row in the game.tilemap:
	for y_tiled=1, #game.tilemap do
		--for each entry of the row
		for x_tiled=1, #game.tilemap[y_tiled] do
			--for each tile in the entry (each entry can have multiple tiles)
			for i=1, #game.tilemap[y_tiled][x_tiled] do
				--make this less typing to reference later
				local tilename = game.tilemap[y_tiled][x_tiled][i]
				--now we're actually using the tile as a key for the "tiles" array from tiles.lua, there was actually a redundant for loop here that couldn't have iterated through anything that i caught by commentating this
				local tile = tiles[tilename]
				--graphics is fairly self-explanatory
				if universalsettings.seetheunseeable or not tile.invisible then
					for ii,graphic in ipairs(tile.graphics) do
						love.graphics.draw(graphic.reference, graphic.quad, ((x_tiled - 1) * tilesize) + graphic.ingameoffset[1], ((y_tiled - 1) * tilesize) + graphic.ingameoffset[2])
					end
				end
			end
		end
	end
	for i=1, #game.loadedobjects do
		game.loadedobjects[i]:draw()
	end
	if game.pausedformenu then
		local r, g, b, a = love.graphics.getColor()
		love.graphics.setColor(0, 0, 0, 0.5)
		love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
		love.graphics.setColor(r, g, b, a)
		printAsTooltip("fact: " .. game.fact)
	end
	if game.editormode then
		printWithOutline("testing level! press esc or tab to return to editor")
	end
end

function game.loadLevel(levelfilename, firstargisactuallevel) --pretty messy. eventually levels will have a class and do a lot more stuff on their own
	--[[for i=1, #game.loadedobjects do
		for ii=1, #game.loadedobjects[i] do
			game.loadedobjects[i][ii]:obliterate()
		end
	end]]
	game.playeramt = 0
	game.loadedobjects = {}
	local levelfile
	--collectgarbage()
	if not firstargisactuallevel then
		levelfile = love.filesystem.read("levelling/"..levelfilename..".txt")
		if levelfile == nil then print "hey your level file ain't jack shit" end
	else levelfile = levelfilename end
	--print("levelling/" .. levelfilename .. ".txt")
	
	--print(levelfile)
	
	--initial parsing (e.g. sections)
	--witness kept saying i was "applying for the fucking iso" for not just using plain seperators instead of using the header/content thing
	local phase = nil
	local subphase = nil
	
	levelfile = correctnewlines(levelfile)
	levelfile = split(levelfile, "\n")
		
	local newmap = {}
	local newtilemap = {}
	local newexits = {}
	local newmusic = ""
	local newoptions = {}
	local newbackground = ""
	local y_tiled = 0
	local maplength = nil
	
	for i, row in ipairs(levelfile) do
		if string.sub(row, 1, 3) == "===" and string.sub(row, -3, -1) == "===" then
			local phasedata = split(string.sub(row, 4, -4), ":")
			phase, subphase = phasedata[1], phasedata[2]
			y_tiled = 0
		else
			--writes padding the beginning of each non-header row with | fixes the problem of === in user input potentially screwing things up. here adding | is optional to ensure... backward-compatibility that's no longer relevant
			if string.sub(row, 1, 1) == "|" then row = string.sub(row, 2, -1) end
			if phase == "MAP" then
				if subphase == nil then subphase = 1 end
				
				if maplength == nil then maplength = #row
				elseif maplength ~= #row then print("mate this row length is inconsistent... subphase: " .. subphase .. ", map length: " .. maplength .. " row length: " .. #row .. ", row (following line):\n" .. row .. "|end") end
				
				--map parsing
				y_tiled = y_tiled + 1
				
				local splitrow = nwidesplit(row, "", 2)
				if newtilemap[y_tiled] == nil then newtilemap[y_tiled] = {} end
				for x_tiled=1, #splitrow do
					if levelsymbols[splitrow[x_tiled]] == nil then print ("not a valid symbol: " .. splitrow[x_tiled]) end
					for i=1, #levelsymbols[splitrow[x_tiled]].objects do
						local obj = levelsymbols[splitrow[x_tiled]].objects[i]
						local options = {}
						local temp = split(obj, ";")
						if #temp >  1 then
							obj = temp[1]
							temp = split(temp[2], "|")
							for i=1, #temp do
								table.insert(options, temp[i])
							end
						end
						--print("hi! some debug info: " .. obj .. ", " .. x_tiled .. ", " .. y_tiled .. ", " .. options[1] .. ", " .. options[2] .. ". there you go :)") ----crashes if there are no options but shhhh
						--print(obj)
						--print(#options)
						--print(game.loadedobjects)
						if objects[obj] == nil then print("THIS AIN'T AN OBJECT CHAMP: " .. obj) end
						table.insert(game.loadedobjects, objects[obj]:setup((x_tiled - 1) * tilesize, (y_tiled - 1) * tilesize, options))
					end
					local temptilesarray = {}
					for i=1, #levelsymbols[splitrow[x_tiled]].tiles do
						table.insert(temptilesarray, levelsymbols[splitrow[x_tiled]].tiles[i])
					end
					if newtilemap[y_tiled][x_tiled] == nil then
						newtilemap[y_tiled][x_tiled] = temptilesarray
					else
						for k,v in ipairs(temptilesarray) do
							table.insert(newtilemap[y_tiled][x_tiled], v)
						end
					end
				end
			elseif phase == "EXITS" then
				table.insert(newexits, row)
			elseif phase == "MUSIC" then
				--music is only supposed to be one row because you can't have more than one track playing
				if newmusic ~= "" then print("loadlevel: changing music when it's already defined??? old val: " .. newmusic) end
				newmusic = row
			elseif phase == "OPTIONS" then
				table.insert(newoptions, row)
			elseif phase == "BACKGROUND" then
				if newbackground ~= "" then print("loadlevel: changing background when it's already defined??? old val: " .. newbackground) end
				newbackground = row
			end
		end
	end
	
	game.liveplayeramt = game.playeramt
	if newbackground == "" then newbackground = game.background end
	return newmap, newtilemap, newexits, newmusic, newoptions, newbackground
end

function game.win(number)
	if number == nil then number = 1 end
	print ("won! time to load " .. game.currentlevelset .. "/" .. game.exits[number])
	game.mapname = game.exits[number]
	if game.mapname == "WINLEVELSET" then
		print("YOU WON THE LEVELSET!!!!!")
		statemachine.setstate("menu")
		game.mapname = "actuallevel"
	else
		game.map, game.tilemap, game.exits, game.currentsong, game.leveloptions, game.background = game.loadLevel(game.currentlevelset .. "/" .. game.exits[number])
		local pauseold = false
		local playevenifsame = false
		--note that playold and playevenifsame are probably naturally mutually exclusive
		for i=1, #game.leveloptions do
			if game.leveloptions[i] == "pauseold" then
				pauseold = true
			elseif game.leveloptions[i] == "playevenifsame" then
				playevenifsame = true
			end
		end
		if game.currentsong ~= audio.activesong or playevenifsame then
			audio.playsong(game.currentsong, false, pauseold)
		end
	end
end

function game.stop()
	game.loadedobjects = {}
	game.map = {}
	game.tilemap = {}
	game.mapname = ""
	game.currentlevelset = ""
	game.cliquemode = false
	if game.editormode then editor.returningfromgame = true end
	game.editormode = false
	game.paused = false
	game.pausemenu = false
	audio.stoploopingsfxall()
	game.paused = false
	game.pausedformenu = false
	if audio.activesong ~= nil then
		song = audio.loadedsongs[audio.activesong]
		if audio.activesongoneshot then
			song:setFilter()
		else
			if song.intro ~= nil then song.intro:setFilter() end
			song.loop:setFilter()
		end
	end
end