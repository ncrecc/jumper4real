commandswithlevelsymbolatend = {
	["rei"] = true,
}
level = class:new()

--[[
	objects = {},
	tilemap = {}, --multiple tiles actually can go on each coordinate so each square here is represented by a table
	options = {},
	filename = nil,
	exits = {},
	width = 512,
	height = 512,
	background = "#341160",
	frozen = false --frozen is like a level-specific version of paused, used for previously visible levels when a diane level is active
]]

level.dontclone = set("tilemap", "objects", "symbolmaps", "tagmaps", "particles")

function level.clone(base) --note this is only intended for gamified levels
	local newlevel = level:new()
	for k,v in pairs(base) do
		if not level.dontclone[k] then
			newlevel[k] = v
		end
	end
	
	newlevel.tilemap = {}
	for y=1, #base.tilemap do
		newlevel.tilemap[y] = {}
		for x=1, #base.tilemap[y] do
			newlevel.tilemap[y][x] = {}
			for i=1, #base.tilemap[y][x] do
				newlevel.tilemap[y][x][i] = base.tilemap[y][x][i]
			end
		end
	end
	
	newlevel.objects = {}
	for i,obj in ipairs(base.objects) do
		local newobj = obj:new() --note: tables probably *will* be copied ad verbum meaning tables belonging to objects that get modified in the cloned level will also be modified in the original level. this could cause issues with, among other things, ogmo's "what things am i touching in the x and y axis" tables and his "what things am i overlapping" table. however the paradigm of "write buggy code that you know is buggy and then only fix it when bugs emerge" has never failed me
		newobj.level = newlevel
		newlevel.objects[i] = newobj
	end
	
	return newlevel
end

function level:findcamerafocus() --wip, ideally a player coming out of an exit should have some special "prioritize me" property. additionally there should be a hierarchy for camera priority: ogmo, then ashley, then have it set up so new player-type objects that cam should follow can have priority similarly set
	local newfocus
	for i,obj in ipairs(self.objects) do
		if obj.player and not obj.gost then
			newfocus = obj
			break
		end
	end
	self.camerafocus = newfocus
end

function level:updatecamera()
	if not self.camerafocus then self:findcamerafocus() end
	if self.camerafocus then
		self.cameraX = (self.camerafocus.x_clamped or self.camerafocus.x) + (self.camerafocus.width / 2) - (game.width / 2)
		--self.cameraX = self.camerafocus.x + (self.camerafocus.width / 2) - (game.width / 2)
		self.cameraX = math.floor(self.cameraX + .5)
		if self.cameraX + game.width > self.width then self.cameraX = self.width - game.width end
		if self.cameraX < 0 then self.cameraX = 0 end
		
		local focusY = self.camerafocus.y_clamped or self.camerafocus.y
		if self.camerafocus.calculate_y_drawat then focusY = self.camerafocus:calculate_y_drawat() end
		local focusheight = self.camerafocus.height -- kludge to ignore reduced height from duck, which can affect the positioning
		if self.camerafocus.ducking then focusheight = self.camerafocus.height + 3 end
		self.cameraY = focusY + (focusheight / 2) - (game.height / 2)
		self.cameraY = math.floor(self.cameraY + .5)
		if self.cameraY + game.height > self.height then self.cameraY = self.height - game.height end
		if self.cameraY < 0 then self.cameraY = 0 end
	end
end

function level:init(levelstring)
	if levelstring then
		if type(levelstring) ~= "string" then error("provided a non-string argument to level.init (type " .. type(levelstring) .. ", tostring " .. tostring(levelstring) .. ")", 3) end
		local phase = nil
		local subphase = nil
		
		levelstring:correctnewlines()
		levelstring = split(levelstring, "\n")
		
		self.comments = {}
		self.symbolmaps = {}
		self.tagmaps = {}
		self.exits = {}
		self.music = nil
		self.options = {}
		self.background = nil
		self.hints = {}
		self.dianelevels = {}
		local readingtags = false
		
		local y_tiled = nil
		local maplength = nil
		local mapheight = nil
		
		local symbolmapisempty = true
		
		for i, row in ipairs(levelstring) do
			local justsetphase = false
			if string.sub(row, 1, 3) == "===" and string.sub(row, -3, -1) == "===" then
				readingtags = false
				if phase == "MAP" and symbolmapisempty then
					print("uh oh, layer " .. subphase .. " was empty")
					self.symbolmaps[subphase].isempty = true
				end
				local phasedata = split(string.sub(row, 4, -4), ":")
				phase, subphase = phasedata[1], phasedata[2]
				if phase == "MAP" then
					if y_tiled and not mapheight then mapheight = y_tiled
					elseif y_tiled and mapheight and mapheight ~= y_tiled then
						print("mapheight not consistent at new map (mapheight: " .. tostring(mapheight) .. ", y_tiled: " .. tostring(y_tiled) .. ", subphase: " .. tostring(subphase) .. ")")
						mapheight = y_tiled
					end
					if not subphase then subphase = 1 end
					if (cheat.isactive("stackem")) or (not subphase) then subphase = 1 end --note that currently, with stackem active, levels are "stacked" as soon as they're loaded in the editor instead of as soon as they're being played in-game. do something about this eventually
					if type(subphase) ~= "number" then subphase = tonumber(subphase) end
					self.tagmaps[subphase] = false
					y_tiled = nil
				end
				if tonumber(subphase) ~= nil then subphase = tonumber(subphase) end
				justsetphase = true
				symbolmapisempty = true
			else
				local mode = "none"
				if string.sub(row, 1, 1) == "|" then mode = "data"; row = string.sub(row, 2, -1)
				elseif string.sub(row, 1, 1) == ">" then mode = "command"; row = string.sub(row, 2, -1)
				end
				
				if mode == "command" then
					local commandtable = split(row, ":")
					local command = commandtable[1]
					local commandsymbol = nil
					if commandswithlevelsymbolatend[command] then commandsymbol = string.sub(row, -2, -1); table.remove(commandtable); end
					if phase == "MAP" then
						if command == "len" then
							maplength = commandtable[2]
						elseif command == "rei" then
							row = string.rep(commandsymbol, commandtable[2])
							mode = "data"
						elseif command == "rep" then
							local splitrow = nwidesplit(leveldata[i - 1], "", 2)
							if not self.symbolmaps[subphase] then self.symbolmaps[subphase] = {} end
							for ii=1, commandtable[2] do
								table.insert(self.symbolmaps[subphase], splitrow)
							end
						elseif command == "tag" then
							readingtags = true
							if y_tiled and not mapheight then mapheight = y_tiled
							elseif y_tiled and mapheight and mapheight ~= y_tiled then
								print("mapheight not consistent at new map (mapheight: " .. tostring(mapheight) .. ", y_tiled: " .. tostring(y_tiled) .. ", subphase: " .. tostring(subphase) .. ")")
								mapheight = y_tiled
							end
							y_tiled = 0
						else print("unrecognized level command \"" .. command .. "\"") end
					end
				end
				
				if mode == "data" then
					if not phase then
						table.insert(self.comments, row)
					elseif phase == "MAP" then
						if not readingtags then	
							if not y_tiled then y_tiled = 0 end
							y_tiled = y_tiled + 1
							if maplength == nil then
								maplength = #row
								self.width = (maplength / 2) * tilesize
							--elseif maplength ~= #row then print("mate this row length is inconsistent... subphase: " .. subphase .. ", map length: " .. maplength .. " row length: " .. #row .. ", row (following line):\n" .. row .. "|end")
							end
							if #row < maplength then
								row = row .. string.rep(" ", maplength - #row)
							end
							if #row > maplength then
								error("row is longer than expected length in chars per row (set by first row in first layer or >len)", 2)
							end
							
							local splitrow = nwidesplit(row, "", 2)
							if symbolmapisempty then
								for ii=1, #splitrow do
									if splitrow[ii] ~= "  " then
										symbolmapisempty = false
										break
									end
								end
							end
							if not self.symbolmaps[subphase] then self.symbolmaps[subphase] = {} end
							table.insert(self.symbolmaps[subphase], splitrow)
						else
							if not self.tagmaps[subphase] then
								self.tagmaps[subphase] = editor.makeEmptyTagMap(maplength, mapheight)
							end
							local tagdata = split(row, ":")
							local tag = tagdata[1]
							local tagcoords = split(tagdata[2], "-")
							local tagcoords1 = split(tagcoords[1], ",")
							local tagcoords2 = split(tagcoords[2], ",")
							local tagmap = self.tagmaps[subphase]
							for y=tagcoords1[1], tagcoords1[2] do
								for x=tagcoords2[1], tagcoords2[2] do
									if not tagmap[y][x] then
										tagmap[y][x] = {tag}
									else
										table.insert(tagmap[y][x], tag)
									end
								end
							end
						end
					elseif phase == "EXITS" then
						table.insert(self.exits, row)
					elseif phase == "HINTS" then
						table.insert(self.hints, row)
					elseif phase == "DIANELEVELS" then
						table.insert(self.dianelevels, row)
					elseif phase == "MUSIC" then
						--music is only supposed to be one row because you can't have more than one track playing
						if self.music then print("loadlevel: changing music when it's already defined??? old val: " .. self.music) end
						self.music = row
					elseif phase == "OPTIONS" then
						--table.insert(self.options, row)
						self.options[row] = true
					elseif phase == "BACKGROUND" then
						if self.background then print("loadlevel: changing background when it's already defined??? old val: " .. self.background) end
						self.background = row
					elseif phase == "NAME" then
						if self.name then print("loadlevel: i guess a level can have two names but can they be on 1 line please. old val: " .. self.name) end
						self.name = row
					else
						if not self[string.lower(phase)] then self[string.lower(phase)] = {} end
						table.insert(self[string.lower(phase)], row)
					end
				end
			end
		end
		if not self.background then self.background = "#341160" end
		if not self.music then self.music = "" end
		self.maplength = maplength --could potentially help out editor a bit to already know what the map length is and then only have to recalculate it when it places
	end
end

function level:gamify(entrance, discard_templates) --discard_templates: discard symbolmaps and tagmaps at the end. we don't need them in memory if the level isn't being played from editor
	self.cameraX = 0
	self.cameraY = 0
	if type(entrance) == "table" then self.entrance = entrance
	else
		self.entrance = {
			number = entrance,
			careening = false,
			doublejumpsused = 0,
			hmom = 0,
			vmom = 0
		}
		if type(entrance) ~= "number" then self.entrance.number = 0; self.entrance.miscdata = entrance; end
	end
	self.objects = {}
	self.tilemap = {}
	self.playeramt = 0
	
	local layerkeys = {}
	for k,_ in pairs(self.symbolmaps) do
		table.insert(layerkeys, k)
	end
	table.sort(layerkeys, function(a,b) return a < b end)
	
	--actual map parsing
	for _,i in ipairs(layerkeys) do
		local map = self.symbolmaps[i]
		for y_tiled,row in ipairs(map) do
			if self.tilemap[y_tiled] == nil then self.tilemap[y_tiled] = {} end
			for x_tiled=1, #row do
				local rawsymbol = row[x_tiled]
				local symbol = levelsymbols[rawsymbol]
				if not symbol then error ("not a valid symbol: " .. row[x_tiled]) end
				for ii=1, #symbol.objects do
					local obj = symbol.objects[ii]
					local options = {}
					local temp = split(obj, "|")
					if #temp >  1 then
						obj = temp[1]
						for iii=2, #temp do
							temp[iii] = split(temp[iii], ":")
							options[temp[iii][1]] = temp[iii][2] or "yes"
						end
					end
					--[[
					local temp = split(obj, ";")
					if #temp >  1 then
						obj = temp[1]
						temp = split(temp[2], "|")
						for iii=1, #temp do
							table.insert(options, temp[iii])
						end
					end
					]]
					if objects[obj] == nil then print("THIS AIN'T AN OBJECT CHAMP: " .. obj) end
					
					local edge = nil
					local magicvalue = nil
					if     y_tiled == #map then
						if     x_tiled == 1    and map[y_tiled - 1][x_tiled] == rawsymbol then edge = "left"
						elseif x_tiled == #row and map[y_tiled - 1][x_tiled] == rawsymbol then edge = "right"
						else edge = "down" end
					elseif y_tiled == 1 then
						if     x_tiled == 1    and map[y_tiled + 1][x_tiled] == rawsymbol then edge = "left"
						elseif x_tiled == #row and map[y_tiled + 1][x_tiled] == rawsymbol then edge = "right"
						else edge = "up" end
					elseif x_tiled == 1 then edge = "left"
					elseif x_tiled == #row then edge = "right" end
					if self.symbolmaps[i + 1] and levelsymbols[self.symbolmaps[i + 1][y_tiled][x_tiled]].magicvalue and objects[obj].magicvalue == nil then
						magicvalue = levelsymbols[self.symbolmaps[i + 1][y_tiled][x_tiled]].magicvalue
					end
					--[[objects are given 6 values at the moment:
						
						the x at which the level suggests they be created
						the y at which the level suggests they be created
						any additional options specified in the levelsymbol via semicolons and vertical bars
						the level itself (important for ogmos to determine if they really want to spawn according to their magic value and the level's entrance)
						whether they were created on an edge (important so win objects and ogmos can use alt behavior)
						the "magic value" they receive if a magic number is above them
					]]
					local newobj = objects[obj]:setup((x_tiled - 1) * tilesize, (y_tiled - 1) * tilesize, options, self, edge, magicvalue)
					if newobj then --object creation functions can "reject" creating an object at all
						if newobj.level == nil then newobj.level = self end --unsure why you'd want to override level but that's fine
						table.insert(self.objects, newobj)
					end
				end
				local temptilesarray = {}
				for ii=1, #symbol.tiles do
					table.insert(temptilesarray, symbol.tiles[ii])
				end
				if self.tilemap[y_tiled][x_tiled] == nil then
					self.tilemap[y_tiled][x_tiled] = temptilesarray
				else
					for k,v in ipairs(temptilesarray) do
						table.insert(self.tilemap[y_tiled][x_tiled], v)
					end
				end
			end
		end
	end
	
	self.height = #self.tilemap * tilesize
	self.dianedepth = 1
	self.liveplayeramt = self.playeramt
	self:updatecamera()
	
	if discard_templates then
		self.symbolmaps = nil
		self.tagmaps = nil
	end
end

function level:freeze()
	self.frozen = true
end

function level:unfreeze()
	self.frozen = false
end

function level:update()
	self.doreset = false
	--[[
	for i,p in ipairs(self.particles) do
		p:update()
	end
	]]
	if not self.frozen then
		local foundcamerafocus = false
		for i=1, #self.objects do
			if self.objects[i] and self.objects[i].update then --first bit is there due to an arcane ancient bug where the length of this would be nonzero even though the table's contents are all nil. probably safe to remove
				self.objects[i]:update()
				if self.objects[i] == self.camerafocus then foundcamerafocus = true end
			end
		end
		if not foundcamerafocus then self.camerafocus = nil end
		self:updatecamera()
		if self.liveplayeramt == 0 and self.playeramt > 0 then
		--also, diane levels need logic so that entering a diane block with a corresponding active level should just bring you to the level instead of cloning it, and make sure they don't end until no more players are inside of it. also make it so you can't enter other diane levels while one diane level is active
			local levelname = self.name or "(unnamed lol)"
			print("all players in level " .. levelname .. " are dead! :(")
			self.doreset = true
		end
	end
end

function level:keypressed(key)
	if not self.frozen then
		for i=1, #self.objects do
			if self.objects[i].keypressed then
				self.objects[i]:keypressed(key)
			end
		end
	end
end

function level:draw()
	local r, g, b, a = love.graphics.getColor()
	love.graphics.setColor(hextocolor(self.background))
	love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	love.graphics.setColor(r, g, b, a)
	
	love.graphics.push()
	love.graphics.translate(-1 * self.cameraX, -1 * self.cameraY)
	--tilemap is like map but instead of containing just symbols it just contains the tile names the symbols would point to
	--for each row in the game.tilemap:
	for y_tiled=1, #self.tilemap do
		--for each entry of the row
		for x_tiled=1, #self.tilemap[y_tiled] do
			--for each tile in the entry (each entry can have multiple tiles)
			for i=1, #self.tilemap[y_tiled][x_tiled] do
				--make this less typing to reference later
				local tilename = self.tilemap[y_tiled][x_tiled][i]
				--now we're actually using the tile as a key for the "tiles" array from tiles.lua, there was actually a redundant for loop here that couldn't have iterated through anything that i caught by commentating this
				local tile = tiles[tilename]
				--graphics is fairly self-explanatory
				if settings.seetheunseeable or not tile.invisible then
					for ii,graphic in ipairs(tile.graphics) do
						love.graphics.draw(graphic.reference, graphic.quad, ((x_tiled - 1) * tilesize) + graphic.ingameoffset[1], ((y_tiled - 1) * tilesize) + graphic.ingameoffset[2])
					end
				end
			end
		end
	end
	local objects_nonsolid = {}
	local objects_solid = {}
	local objects_late = {}
	for _,obj in ipairs(self.objects) do
		if obj.drawlate then table.insert(objects_late, obj)
		elseif not obj.solid then table.insert(objects_nonsolid, obj)
		else table.insert(objects_solid, obj) end
	end
	for i=1, #objects_nonsolid do
		objects_nonsolid[i]:draw()
	end
	for i=1, #objects_solid do
		objects_solid[i]:draw()
	end
	for i=1, #objects_late do
		objects_late[i]:draw()
	end
	love.graphics.pop()
	--[[
	love.graphics.setColor(0, 0, 0, a)
	love.graphics.rectangle("fill", 400, 0, 400, 16)
	love.graphics.setColor(r, g, b, a)
	love.graphics.print(self.camerafocus.x, 400)
	love.graphics.print(self.camerafocus.y, 416)
	love.graphics.print(booltostr(self.camerafocus), 432)
	]]
end