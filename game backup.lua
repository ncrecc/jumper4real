objects = {}
objectfiles = love.filesystem.getDirectoryItems("objection")
for i=1, #objectfiles do
	s = objectfiles[i]
	if string.sub(s, #s - 3) == ".lua" then
		object = require ("objection/" .. string.sub(s, 1, #s - 4))
		objects[string.sub(s, 1, #s - 4)] = object
	end
end

game.playeramt = 0
game.liveplayeramt = 0
game.loadedobjects = {}
game.mapname = "test"
game.exits = {"actuallevel"}
game.map = {}
game.tilemap = {} --multiple tiles actually can go on each coordinate so each square here is represented by a table

game = {
}

function game.begin()
	game.map, game.tilemap = game.loadLevel(game.mapname)
end

function game.update(dt)
	audio.update()
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
		game.map, game.tilemap = game.loadLevel(game.mapname)
	end
end

function game.keypressed(key)
	for i=1, #game.loadedobjects do
		if game.loadedobjects[i].keyreactions and game.loadedobjects[i].keyreactions[key] then
			game.loadedobjects[i]:keypressed(key)
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
	--game.tilemap is like map but instead of containing just symbols it just contains the tile names the symbols would point to
	--for each row in the game.tilemap:
	for y_tiled=1, #game.tilemap do
		--for each entry of the row (each entry can have multiple tiles)
		for x_tiled=1, #game.tilemap[y_tiled] do
			--for each tile in the entry
			for i=1, #game.tilemap[y_tiled][x_tiled] do
				--make this less typing to reference later
				local tilename = game.tilemap[y_tiled][x_tiled][i]
				--now we're actually using the tile as a key for the "tiles" array from tiles.lua, there was actually a redundant for loop here that couldn't have iterated through anything that i caught by commentating this
				local tile = tiles[tilename]
				--the way gfxoverride works is that if it exists, it's a table, and the game draws each graphic name in order (there can of course be just one entry in the table . if it doesn't exist, then the game just looks for the name of the tile as the graphic name
				if tile.gfxoverride then
					for ii=1, #tile.gfxoverride do
						love.graphics.draw(graphics.load(tile.gfxoverride[ii]), (x_tiled - 1) * tilesize, (y_tiled - 1) * tilesize)
					end
				else
					love.graphics.draw(graphics.load(tilename), (x_tiled - 1) * tilesize, (y_tiled - 1) * tilesize)
				end
			end
		end
	end
	for i=1, #game.loadedobjects do
		game.loadedobjects[i]:draw()
	end
end

function game.loadLevel(levelfilename)
	--[[for i=1, #game.loadedobjects do
		for ii=1, #game.loadedobjects[i] do
			game.loadedobjects[i][ii]:obliterate()
		end
	end]]
	game.playeramt = 0
	game.loadedobjects = {}
	--collectgarbage()
	levelfile = love.filesystem.read("levelling/"..levelfilename..".txt")
	if levelfile == nil then print "hey your level file ain't jack shit" end
	
	
	--section parsing
	mapheader = "---MAP---"
	mapcontent = ""
	exitsheader = "---EXITS---"
	exitscontent = ""
	
	headers = {mapheader, exitsheader}
	
	mapheaderstart, mapheaderend = string.find(levelfile, mapheader, 1, true)
	exitsheaderstart, exitsheaderend = string.find(levelfile, exitsheader, 1, true)
	mapcontent = string.sub(levelfile, mapheaderend, exitsheaderstart)
	exitscontent = string.sub(levelfile, exitsheaderend)
	
	
	--breaking change is changing levelfile to mapcontent
	local newmap = split(levelfile, "\n")
	local newtilemap = {}
	templength = #newmap
	for i=1, #newmap do
		newmap[i] = split(newmap[i], "")
		if i ~= #newmap then
			table.remove(newmap[i], #newmap[i]) --splitting by zero-length string results in dummy elements at the end, except for the last row
		end
	end
	if #newmap == 0 then error(); return nil; end --why would you feed it an empty map
	for y_tiled=1, #newmap do
		table.insert(newtilemap, {})
		for x_tiled=1, #newmap[y_tiled] do
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
				--print("hi! some debug info: " .. obj .. ", " .. x_tiled .. ", " .. y_tiled .. ", " .. options[1] .. ", " .. options[2] .. ". there you go :)") --crashes if there are no options but shhhh
				--print(obj)
				--print(#options)
				--print(game.loadedobjects)
				table.insert(game.loadedobjects, objects[obj]:setup((x_tiled - 1) * tilesize, (y_tiled - 1) * tilesize, options))
			end
			local temptilesarray = {}
			for i=1, #levelsymbols[newmap[y_tiled][x_tiled]].tiles do
				table.insert(temptilesarray, levelsymbols[newmap[y_tiled][x_tiled]].tiles[i])
			end
			table.insert(newtilemap[y_tiled], temptilesarray)
		end
	end
	game.liveplayeramt = game.playeramt
	return newmap, newtilemap
end

function game.win(number)
	print ("won! time to load " .. exits[number])
	game.mapname = exits[number]
	game.map, game.tilemap = game.loadLevel(exits[number])
end

function game.stop()
	game.loadedobjects = {}
	game.map = {}
	game.tilemap = {}
end