playeramt = 0
liveplayeramt = 0
loadedobjects = {}
leveloptions = {}
mapname = ""
exits = {}
currentlevelset = ""
currentsong = ""
map = {}
tilemap = {} --multiple tiles actually can go on each coordinate so each square here is represented by a table

game = {
}

function game.begin()
	map, tilemap, exits, currentsong, leveloptions = game.loadLevel(currentlevelset .. "/" .. mapname)
	music:play(currentsong, false)
end

function game.update(dt)
	--[=[
	for i=1, #objectnamelist do
		if loadedobjects[objectnamelist[i]] ~= nil then
			for ii=1, #loadedobjects[objectnamelist[i]] do
				loadedobjects[objectnamelist[i]][ii]:update()
			end
		end
	end
	]=]
	for i=1, #loadedobjects do
		if loadedobjects[i] then --briefly after loading a level, all contents of loadedobjects are set to nil - loadedobjects = {} seems first to set contents to nil and then clear it very slightly later. calling garbage collection early doesn't help with this
			loadedobjects[i]:update()
		end
	end
	if liveplayeramt == 0 then
		print("all players are dead! :( reinitializing map")
		map, tilemap, exits = game.loadLevel(currentlevelset .. "/" .. mapname)
	end
end

function game.keypressed(key)
	for i=1, #loadedobjects do
		if loadedobjects[i].keyreactions and loadedobjects[i].keyreactions[key] then
			loadedobjects[i]:keypressed(key)
		end
	end
	if key == "escape" then
		statemachine.setstate("menu")
	end
	--[[
   if key == "rctrl" then
      debug.debug()
   end
   ]]--
end

function game.draw()
	--ok i'll try to break this down step-by-step for future me's convenience
	--tilemap is like map but instead of containing just symbols it just contains the tile names the symbols would point to
	--for each row in the tilemap:
	for y_tiled=1, #tilemap do
		--for each entry of the row
		for x_tiled=1, #tilemap[y_tiled] do
			--for each tile in the entry (each entry can have multiple tiles)
			for i=1, #tilemap[y_tiled][x_tiled] do
				--make this less typing to reference later
				local tilename = tilemap[y_tiled][x_tiled][i]
				--now we're actually using the tile as a key for the "tiles" array from tiles.lua, there was actually a redundant for loop here that couldn't have iterated through anything that i caught by commentating this
				local tile = tiles[tilename]
				--the way gfxoverride works is that if it exists, it's a table, and the game draws each graphic name in order (there can of course be just one entry in the table). if it doesn't exist, then the game just looks for the name of the tile as the graphic name
				if tile.gfxoverride then
					for ii=1, #tile.gfxoverride do
						love.graphics.draw(graphics:load(tile.gfxoverride[ii]), (x_tiled - 1) * tilesize, (y_tiled - 1) * tilesize)
					end
				elseif tile.invisible then
					if universalsettings.seetheunseeable then
						love.graphics.draw(graphics:load(tilename), (x_tiled - 1) * tilesize, (y_tiled - 1) * tilesize)
					end
				else
					love.graphics.draw(graphics:load(tilename), (x_tiled - 1) * tilesize, (y_tiled - 1) * tilesize)
				end
			end
		end
	end
	for i=1, #loadedobjects do
		loadedobjects[i]:draw()
	end
end

function game.loadLevel(levelfilename)
	--[[for i=1, #loadedobjects do
		for ii=1, #loadedobjects[i] do
			loadedobjects[i][ii]:obliterate()
		end
	end]]
	playeramt = 0
	loadedobjects = {}
	--collectgarbage()
	levelfile = love.filesystem.read("levelling/"..levelfilename..".txt")
	if levelfile == nil then print "hey your level file ain't jack shit" end
	--print("levelling/" .. levelfilename .. ".txt")
	
	--print(levelfile)
	
	--initial parsing (e.g. sections)
	--wn kept saying i was "applying for the fucking iso" for not just using plain seperators instead of using the header/content thing
	mapheader = "\r\n===MAP===\r\n"
	mapcontent = ""
	exitsheader = "\r\n===EXITS===\r\n"
	exitscontent = ""
	musicheader = "\r\n===MUSIC===\r\n"
	musiccontent = ""
	optionsheader = "\r\n===OPTIONS===\r\n"
	optionscontent = ""
	
	headers = {mapheader, exitsheader, musicheader, optionsheader} --this is never used again. hm
	
	mapheaderstart, mapheaderend = string.find(levelfile, mapheader)
	--print(mapheaderstart, mapheaderend)
	exitsheaderstart, exitsheaderend = string.find(levelfile, exitsheader)
	--print(exitsheaderstart, exitsheaderend)
	musicheaderstart, musicheaderend = string.find(levelfile, musicheader)
	--print(musicheaderstart, musicheaderend)
	optionsheaderstart, optionsheaderend = string.find(levelfile, optionsheader)
	--print(optionsheaderstart, optionsheaderend)
	--print(mapheaderstart, mapheaderend)
	--print(exitsheaderstart, exitsheaderend)
	mapcontent = string.sub(levelfile, mapheaderend + 1, exitsheaderstart - 1)
	exitscontent = string.sub(levelfile, exitsheaderend + 1, musicheaderstart - 1)
	musiccontent = string.sub(levelfile, musicheaderend + 1, optionsheaderstart - 1)
	optionscontent = string.sub(levelfile, optionsheaderend + 1)
	
	
	
	--mapcontent parsing
	--print "heers da map:"
	--print(mapcontent)
	local newmap = split(mapcontent, "\r\n")
	local newtilemap = {}
	templength = #newmap
	for i=1, #newmap do
		newmap[i] = split(newmap[i], "")
		--i thought this part was a bug with split returning a blank item at the end of every row, or something, but it turned out to be an issue from splitting by \n instead of \r\n. comp sci get your shit together you have 5 different characters that all mean newline and sometimes you sequence them together to mean still one newline. smfh
		--[[if i ~= #newmap then
			table.remove(newmap[i], #newmap[i])
		end]]
	end
	if #newmap == 0 then error(); return nil; end --why would you feed it an empty map
	for y_tiled=1, #newmap do
		table.insert(newtilemap, {})
		for x_tiled=1, #newmap[y_tiled] do
			if levelsymbols[newmap[y_tiled][x_tiled]] == nil then print ("not a valid symbol: " .. newmap[y_tiled][x_tiled]) end
			for i=1, #levelsymbols[newmap[y_tiled][x_tiled]].objects do
				obj = levelsymbols[newmap[y_tiled][x_tiled]].objects[i]
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
				--print(loadedobjects)
				table.insert(loadedobjects, objects[obj]:setup((x_tiled - 1) * tilesize, (y_tiled - 1) * tilesize, options))
			end
			local temptilesarray = {}
			for i=1, #levelsymbols[newmap[y_tiled][x_tiled]].tiles do
				table.insert(temptilesarray, levelsymbols[newmap[y_tiled][x_tiled]].tiles[i])
			end
			table.insert(newtilemap[y_tiled], temptilesarray)
		end
	end
	liveplayeramt = playeramt
	
	
	--exitscontent parsing
	newexits = split(exitscontent, "\r\n")
	
	
	--musiccontent parsing. this is just a single string
	newmusic = musiccontent
	
	
	--optionscontent parsing
	newoptions = split(optionscontent, "\r\n")
	
	
	return newmap, newtilemap, newexits, newmusic, newoptions
end

function game.win(number)
	print ("won! time to load " .. currentlevelset .. "/" .. exits[number])
	mapname = exits[number]
	if mapname == "WINLEVELSET" then
		print("YOU WON THE LEVELSET!!!!!")
		statemachine.setstate("menu")
		mapname = "actuallevel"
	else
		map, tilemap, exits, currentsong, leveloptions = game.loadLevel(currentlevelset .. "/" .. exits[number])
		local pauseold = false
		local playevenifsame = false
		--note that playold and playevenifsame are probably naturally mutually exclusive
		for i=1, #leveloptions do
			if leveloptions[i] == "pauseold" then
				pauseold = true
			elseif leveloptions[i] == "playevenifsame" then
				playevenifsame = true
			end
		end
		if currentsong ~= music.activesong or playevenifsame then
			music:play(currentsong, false, pauseold)
		end
	end
end

function game.stop()
	loadedobjects = {}
	map = {}
	tilemap = {}
	mapname = "actuallevel"
	currentlevelset = "levelset1"
end