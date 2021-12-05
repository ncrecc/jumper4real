editor = {
	lmbtile = "#",
	rmbtile = ".",
	mmbtile = "X",
	page = 1,
	addedheight = tilesize * 4,
	addedwidth = tilesize * 4,
	tilebaroffset_x = tilesize,
	tilebaroffset_y = tilesize
}

function editor.loadLevel(levelfilename) --this one's a bit different than game's loadlevel because it directly receives the level symbols
	levelfile = love.filesystem.read(levelfilename..".txt")
	if levelfile == nil then print "hey your level file ain't jack shit" end
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
	local newsymbolmap = split(mapcontent, "\r\n")
	templength = #newsymbolmap
	if #newsymbolmap == 0 then error(); return nil; end --why would you feed it an empty map
	for i=1, templength do
		newsymbolmap[i] = split(newsymbolmap[i], "")
	end
	
	--exitscontent parsing
	newexits = split(exitscontent, "\r\n")
	
	
	--musiccontent parsing. this is just a single string
	newmusic = musiccontent
	
	
	--optionscontent parsing
	newoptions = split(optionscontent, "\r\n")
	
	
	return newsymbolmap, newexits, newmusic, newoptions
end

editor.symbolmap, editor.exits, editor.music, editor.options = editor.loadLevel("defaultlevel")

function editor.begin()
	love.window.updateMode(512 + editor.addedwidth, 512 + editor.addedheight)
	music:play("groove")
end

function editor.update(dt)
	if love.mouse.isDown(1, 2, 3) then
		local x, y = love.mouse.getPosition()
		if y < 512 and x < 512 then
			local x_tiled = 1 + math.floor(x / tilesize)
			local y_tiled = 1 + math.floor(y / tilesize)
			local tile = nil
			if love.mouse.isDown(1) then tile = editor.lmbtile
			elseif love.mouse.isDown(2) then tile = editor.rmbtile
			elseif love.mouse.isDown(3) then tile = editor.mmbtile end
			editor.symbolmap[y_tiled][x_tiled] = tile
		elseif x < 512 then
			local x_tiled_fortilebar = 1 + math.floor((x - editor.tilebaroffset_x) / tilesize)
			local y_tiled_fortilebar = 1 + math.floor((y - 512 - editor.tilebaroffset_y) / tilesize)
			
			if editor_pages[editor.page][y_tiled_fortilebar] ~= nil then
				if editor_pages[editor.page][y_tiled_fortilebar][x_tiled_fortilebar] ~= nil then
					local symbol = editor_pages[editor.page][y_tiled_fortilebar][x_tiled_fortilebar]
					if love.mouse.isDown(1) then editor.lmbtile = symbol
					elseif love.mouse.isDown(2) then editor.rmbtile = symbol
					elseif love.mouse.isDown(3) then editor.mmbtile = symbol end
				end
			end
		end
	end
end

function editor.keypressed(key)
	if key == "escape" then
		statemachine.setstate("menu")
		menu.picker = 3
	end
end

function editor.drawSymbol(realsymbol, x, y)
	symbol = levelsymbols[realsymbol]
	for i=1, #symbol.tiles do
		--make this less typing to reference later
		local tilename = symbol.tiles[i]
		--now we're actually using the tile as a key for the "tiles" array from tiles.lua, there was actually a redundant for loop here that couldn't have iterated through anything that i caught by commentating this
		local tile = tiles[tilename]
		--the way gfxoverride works is that if it exists, it's a table, and the game draws each graphic name in order (there can of course be just one entry in the table). if it doesn't exist, then the game just looks for the name of the tile as the graphic name
		if tile.gfxoverride then
			for ii=1, #tile.gfxoverride do
				love.graphics.draw(graphics:load(tile.gfxoverride[ii]), x, y)
			end
		else
			love.graphics.draw(graphics:load(tilename), x, y)
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
		else
			graphictodraw = graphics:load(objectname)
		end
		love.graphics.draw(graphictodraw, x, y)
	end
end

function editor.draw()
	local r, g, b, a = love.graphics.getColor()
	love.graphics.setColor(0.2, 0.2, 0.2)
	love.graphics.rectangle("fill", 0, 512, 512 + editor.addedwidth, 512)
	love.graphics.rectangle("fill", 512, 0, editor.addedwidth, 512)
	love.graphics.setColor(r, g, b, a)
	for y_tiled=1, #editor.symbolmap do
		--for each entry of the row
		for x_tiled=1, #editor.symbolmap[y_tiled] do
			editor.drawSymbol(editor.symbolmap[y_tiled][x_tiled], (x_tiled - 1) * tilesize, (y_tiled - 1) * tilesize)
		end
	end
	for i=1, #editor_pages[editor.page] do
		for ii=1, #editor_pages[editor.page][i] do
			local symbol = editor_pages[editor.page][i][ii]
			editor.drawSymbol(symbol, ((ii - 1) * tilesize) + editor.tilebaroffset_x, ((i - 1) * tilesize) + editor.tilebaroffset_y + 512)
			local selectgraphics = {}
			if symbol == editor.lmbtile then table.insert(selectgraphics, "select_lmb") end
			if symbol == editor.rmbtile then table.insert(selectgraphics, "select_rmb") end
			if symbol == editor.mmbtile then table.insert(selectgraphics, "select_mmb") end
			for iii=1, #selectgraphics do love.graphics.draw(graphics:load(selectgraphics[iii]), ((ii - 1) * tilesize) + editor.tilebaroffset_x, ((i - 1) * tilesize) + editor.tilebaroffset_y + 512) end
		end
	end
end

function editor.stop()
	love.window.updateMode(512, 512)
end