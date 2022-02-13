--written by bert. actually i think you can just assume anything in this project is something i've written unless otherwise specified. some very basic early stuff (in game.lua) was made by abagail but that's about it

mobtools = {}

--[[
function mobtools.collideAgainstThings(mob)

end

function mobtools.fetchProjectedPosition(mob)

end
]]

function mobtools.doCollisionScan(axis, collider, dontusemask, ignoretype, ignoreunlessvar, level)
	ignoretype = ignoretype or {}
	ignoreunlessvar = ignoreunlessvar or {}
	level = level or collider.level
	--this could still use some more optimization (e.g. determine what rows/columns to scan based on collider's position and momentum without iterating through them first)
	local dir = "none"
	if axis == "horizontal" then
		if collider.hmom < 0 then dir = "left"
		elseif collider.hmom > 0 then dir = "right" end
	elseif axis == "vertical" then
		if collider.vmom < 0 then dir = "up"
		elseif collider.vmom > 0 then dir = "down" end
	end
	local collisiondir = "none"
	local suggestedposition = nil --where collisionscan suggests the collider's x should be if the collider collides with something. this will only ever be one number (or nil if no collision occurs) since collisionscan only works in one axis at a time
	local collidees = {}
	local function updateValuesToReturn (newcollisiondir, newsuggestedposition, newcollidees) --if you change this, change the matching function in doCollisionCheck
		if collisiondir == "none" then collisiondir = newcollisiondir end
		
		--make sure suggested position is always whichever position would make the player collide earlier
		if newsuggestedposition ~= nil then
			if suggestedposition == nil then suggestedposition = newsuggestedposition else
					if (dir == "left"  or dir == "up")   and newsuggestedposition > suggestedposition then suggestedposition = newsuggestedposition
				elseif (dir == "right" or dir == "down") and newsuggestedposition < suggestedposition then suggestedposition = newsuggestedposition end
			end
		end
		
		if newcollidees == nil then print("newcollidees is nil"); newcollidees = {} end
		
		for k,v in ipairs(newcollidees) do
			table.insert(collidees, v)
		end
	end
	if axis == "horizontal" and collider.hmom ~= 0 then
		if not collider.collisioncondition or collider:collisioncondition("levelborder") then
			local collider_rightedge = collider.x + collider.width - 1
			local collider_leftedge = collider.x
			--colliding against the level borders
			if collider_rightedge + collider.hmom + 1 >= level.width and dir == "right" then
				--[[
				if collider_rightedge < level.width then
					collider.x = (level.width - collider.width) + 1
				end
				collider.hmom = 0
				collider.tempfriction = nil
				]]
				updateValuesToReturn("right", level.width - collider.width, {tiles["levelborder"]})
			elseif collider_leftedge + collider.hmom < 0 and dir == "left" then
				--[[
				if collider_leftedge >= 0 then
					collider.x = 0
				end
				collider.hmom = 0
				collider.tempfriction = nil
				]]
				updateValuesToReturn("left", 0, {tiles["levelborder"]})
			end
		end
		local collider_top = collider.y
		local collider_bottom = collider.y + collider.height - 1
		local collider_leftedge = collider.x
		local collider_rightedge = collider.x + collider.width - 1
		for y_tiled=1, #level.tilemap do
			local tile_top = (y_tiled - 1) * tilesize
			local tile_bottom = ((y_tiled - 1) * tilesize) + tilesize - 1
			if collider_top <= tile_bottom and collider_bottom >= tile_top then --if collider is in range to collide with any tiles here
				for x_tiled=1, #level.tilemap[y_tiled] do
					for i=1, #level.tilemap[y_tiled][x_tiled] do
						local tilename = level.tilemap[y_tiled][x_tiled][i]
						local tile = tiles[tilename]
						if tile.solid then
							tile.type = tilename
							tile.x = ((x_tiled - 1) * tilesize) + (tile.hitboxXoffset or 0)
							tile.y = ((y_tiled - 1) * tilesize) + (tile.hitboxYoffset or 0)
							tile.hmom = 0
							tile.vmom = 0
							tile.width = tile.hitboxwidth or tilesize
							tile.height = tile.hitboxheight or tilesize
							if not collider.collisioncondition or collider:collisioncondition(tile) then
								updateValuesToReturn(mobtools.doCollisionCheck(axis, collider, tile))
							end
						end
					end
				end
			end
		end
		for i=1, #level.objects do
			obj = level.objects[i]
			--gost's block shouldn't collide with ogmos
			--if not (collider.gost and obj.type == "ogmo") then
			local obj_top = obj.y
			local obj_bottom = obj.y + obj.height - 1
			if obj.solid and collider_top <= obj_bottom and collider_bottom >= obj_top then
				if not collider.collisioncondition or collider:collisioncondition(obj) then
					updateValuesToReturn(mobtools.doCollisionCheck(axis, collider, obj))
				end
			end
		end
	elseif axis == "vertical" and collider.vmom ~= 0 then
		local collider_bottom = collider.y + collider.height - 1
		local collider_top = collider.y
		if not collider.collisioncondition or collider:collisioncondition("levelborder") then
			if level.options.bottombordersolid and collider_bottom + collider.vmom + 1 >= level.height and dir == "down" then
				--return "down", level.height - collider.height, {"levelborder"}
				updateValuesToReturn("down", level.height - collider.height, {"levelborder"})
			elseif collider_top + collider.vmom < 0 and dir == "up" then
				updateValuesToReturn("up", 0, {"levelborder"})
			end
		end
		local collider_top = collider.y
		local collider_bottom = collider.y + collider.height - 1
		local collider_leftedge = collider.x
		local collider_rightedge = collider.x + collider.width - 1
		for y_tiled=1, #level.tilemap do
			for x_tiled=1, #level.tilemap[y_tiled] do
				local tile_leftedge = (x_tiled - 1) * tilesize
				local tile_rightedge = ((x_tiled - 1) * tilesize) + tilesize - 1
				if collider_leftedge <= tile_rightedge and collider_rightedge >= tile_leftedge then
					for i=1, #level.tilemap[y_tiled][x_tiled] do
						local tilename = level.tilemap[y_tiled][x_tiled][i]
						local tile = tiles[tilename]
						if tile.solid then
							tile.type = tilename
							tile.x = ((x_tiled - 1) * tilesize) + (tile.hitboxXoffset or 0)
							tile.y = ((y_tiled - 1) * tilesize) + (tile.hitboxYoffset or 0)
							tile.hmom = 0
							tile.vmom = 0
							tile.width = tile.hitboxwidth or tilesize
							tile.height = tile.hitboxheight or tilesize
							if not collider.collisioncondition or collider:collisioncondition(tile) then
								updateValuesToReturn(mobtools.doCollisionCheck(axis, collider, tile))
							end
						end
					end
				end
			end
		end
		for i=1, #level.objects do
			obj = level.objects[i]
			--if not (collider.gost and obj.type == "ogmo") then
			local obj_leftedge = obj.x
			local obj_rightedge = obj.x + obj.width - 1
			if obj.solid and collider_leftedge <= obj_rightedge and collider_rightedge >= obj_leftedge then
				if not collider.collisioncondition or collider:collisioncondition(obj) then
					updateValuesToReturn(mobtools.doCollisionCheck(axis, collider, obj))
				end
			end
		end
	end
	return collisiondir, suggestedposition, collidees
end

function mobtools.doCollisionCheck(axis, collider, collidee, dontusemask)
	--we enjoy typing. mirroring stuff from docollisionscan
	local dir = "none"
	if axis == "horizontal" then
		if collider.hmom < 0 then dir = "left"
		elseif collider.hmom > 0 then dir = "right" end
	elseif axis == "vertical" then
		if collider.vmom < 0 then dir = "up"
		elseif collider.vmom > 0 then dir = "down" end
	end
	local collisiondir = "none"
	local suggestedposition = nil
	local collidees = {}
	
	local function updateValuesToReturn (newcollisiondir, newsuggestedposition, newcollidees) --if you change this, change the matching function in doCollisionScan
		if collisiondir == "none" then collisiondir = newcollisiondir end
		
		--make sure suggested position is always whichever position would make the player collide earlier
		if newsuggestedposition ~= nil then
			if suggestedposition == nil then suggestedposition = newsuggestedposition else
					if (dir == "left"  or dir == "up")   and newsuggestedposition > suggestedposition then suggestedposition = newsuggestedposition
				elseif (dir == "right" or dir == "down") and newsuggestedposition < suggestedposition then suggestedposition = newsuggestedposition end
			end
		end
		
		if newcollidees == nil then print("newcollidees is nil"); newcollidees = {} end
		
		for k,v in ipairs(newcollidees) do
			table.insert(collidees, v)
		end
	end
	
	local collider_rightedge = collider.x + collider.width - 1
	local collider_leftedge = collider.x
	local collidee_rightedge = collidee.x + collidee.width - 1
	local collidee_leftedge = collidee.x
	local collider_bottom = collider.y + collider.height - 1
	local collider_top = collider.y
	local collidee_bottom = collidee.y + collidee.height - 1
	local collidee_top = collidee.y
	local y_min
	local y_max
	local x_min
	local x_max
	if axis == "horizontal" and collider_top <= collidee_bottom and collider_bottom >= collidee_top then
		if collidee.mask ~= nil then --note: collidee is allowed to have a mask, but NOT collider
			y_min = (math.floor(collider_top) - collidee_top) + 1 --top of collider relative to mask, plus 1 because this is calculated using 0-indexing (screen coordinates) but is now being used for a table which uses 1-indexing
			y_max = (math.floor(collider_bottom) - collidee_top) + 1 --bottom of collider relative to mask, plus 1
			if y_min < 1 then y_min = 1 end
			if y_max > collidee.height then y_max = collidee.height end
		end
		if dir == "right" then
			if collidee_rightedge > collider_rightedge then --if right edge of tile is to the right of right edge of player. this means player is potentially able to collide with the block or any mask pixels of the block
				if collidee_leftedge - collider_rightedge - 1 --[[1 is subtracted here because if ogmo is flush with the wall that counts as being 0 pixels away from it]] <= collider.hmom then --checks that distance between left surface of tile and right surface of ogmo is less than ogmo's momentum. this includes if ogmo is inside the tile and moving further
					if collidee.mask == nil then
						--[[
						if not checkonly then
							collider.x = collidee_leftedge - collider.width
							collider.hmom = 0
							collider.tempfriction = nil
						end
						]]
						updateValuesToReturn("right", collidee_leftedge - collider.width, {collidee})
						--[[for i=1, #collidee.ontoucheffects do
							table.insert(ontoucheffects, collidee.ontoucheffects[i])
						end]]
					else
						--what we do for mask collision is, basically: figure out what area a mask pixel needs to be in for ogmo to collide with it given ogmo's current momentum, then if a pixel is found in that area, set ogmo flush against it and cancel his momentum
						--[[ reuse this for vertical downward collision
						for i = 1, #collidee.mask do
							y_pixeled = i + collidee_top
							for ii = 1, #collidee.mask[i] do
								x_pixeled = (ii - 1) + collidee_leftedge
							end
						end
						--]]
						local x_min = (math.floor(collider_rightedge) - collidee_leftedge) + 1
						local x_max = x_min + math.ceil(collider.hmom)
						if x_min < 1 then x_min = 1 end
						if x_max > collidee.width then x_max = collidee.width end
						local x_mask = x_min
						local y_mask = y_min
						--[[
						for i=1, #collidee.mask do
							local printstring = ""
							for ii=1, #collidee.mask[i] do
								printthing = "0"
								if collidee.mask[i][ii] then printthing = "1" end
								printstring = printstring .. printthing
							end
							print(i .. ". " .. printstring)
						end
						--]]
						
						--[[print("!!!!!")
						if x_mask > x_max then
							print("x mask: " .. x_mask)
							print("x max: " .. x_max)
						end]]
						while x_mask <= x_max do
							--[[print(y_mask)
							print(x_mask)
							print("----")]]
							if collidee.mask[y_mask][x_mask] then
								--[[print("collided!")
								print("=========")]]
								updateValuesToReturn("right", (x_mask - 1) + collidee_leftedge - collider.width, {collidee})
								--[[for i=1, #collidee.ontoucheffects do
									table.insert(ontoucheffects, collidee.ontoucheffects[i])
								end]]
							end
							y_mask = y_mask + 1
							if y_mask > y_max then
								y_mask = y_min
								x_mask = x_mask + 1
							end
						end
						--print("====")
					end
				end
			end
		elseif dir == "left" then
			if collidee_leftedge < collider_leftedge then
				if collidee_rightedge - collider_leftedge + 1 >= collider.hmom then
					if collidee.mask == nil then
						updateValuesToReturn("left", collidee_rightedge + 1, {collidee})
					else
						local x_max = (math.ceil(collider_leftedge) - collidee_leftedge)
						local x_min = x_max + math.floor(collider.hmom)
						if x_min < 1 then x_min = 1 end
						if x_max > collidee.width then x_max = collidee.width end
						local x_mask = x_max
						local y_mask = y_min
						while x_mask >= x_min do
							if collidee.mask[y_mask][x_mask] then
								updateValuesToReturn("left", (x_mask - 1) + collidee_leftedge + 1, {collidee})
							end
							y_mask = y_mask + 1
							if y_mask > y_max then
								y_mask = y_min
								x_mask = x_mask - 1
							end
						end
					end
				end
			end
		end
	elseif axis == "vertical" and collider_leftedge <= collidee_rightedge and collider_rightedge >= collidee_leftedge then
		if collidee.mask ~= nil then --note: collidee is allowed to have a mask, but NOT collider
			x_min = (math.floor(collider_leftedge) - collidee_leftedge) + 1
			x_max = (math.floor(collider_rightedge) - collidee_leftedge) + 1
			if x_min < 1 then x_min = 1 end
			if x_max > collidee.width then x_max = collidee.width end
		end
		if dir == "down" then
			if collidee_bottom > collider_bottom then
				if collidee_top - collider_bottom - 1 <= collider.vmom then
					if collidee.mask == nil then
						updateValuesToReturn("down", collidee_top - collider.height, {collidee})
					else
						local y_min = (math.floor(collider_bottom) - collidee_top) + 1
						local y_max = y_min + math.ceil(collider.vmom)
						if y_min < 1 then y_min = 1 end
						if y_max > collidee.height then y_max = collidee.height end
						local y_mask = y_min
						local x_mask = x_min
						while y_mask <= y_max do
							if collidee.mask[y_mask][x_mask] then
								updateValuesToReturn("down", (y_mask - 1) + collidee_top - collider.height, {collidee})
							end
							x_mask = x_mask + 1
							if x_mask > x_max then
								x_mask = x_min
								y_mask = y_mask + 1
							end
						end
					end
				end
			end
		elseif dir == "up" then
			if collidee_top < collider_top then
				if collidee_bottom - collider_top + 1 >= collider.vmom then
					if collidee.mask == nil then
						updateValuesToReturn("up", collidee_bottom + 1, {collidee})
					else
						local y_max = (math.ceil(collider_top) - collidee_top)
						local y_min = y_max + math.floor(collider.vmom)
						if y_min < 1 then y_min = 1 end
						if y_max > collidee.height then y_max = collidee.height end
						local y_mask = y_max
						local x_mask = x_min
						while y_mask >= y_min do
							if collidee.mask[y_mask][x_mask] then
								updateValuesToReturn("up", (y_mask - 1) + collidee_top + 1, {collidee})
							end
							x_mask = x_mask + 1
							if x_mask > x_max then
								x_mask = x_min
								y_mask = y_mask - 1
							end
						end
					end
				end
			end
		end
	end
	return collisiondir, suggestedposition, collidees
end

function mobtools.doOverlapScan(collider, objectsonly, level)
	level = level or collider.level
	local collidees = {}
	if not objectsonly then
		local collider_top = collider.y
		local collider_bottom = collider.y + collider.height - 1
		local collider_leftedge = collider.x
		local collider_rightedge = collider.x + collider.width - 1
		for y_tiled=1, #level.tilemap do
			local tile_top = (y_tiled - 1) * tilesize
			local tile_bottom = ((y_tiled - 1) * tilesize) + tilesize - 1
			if collider_top <= tile_bottom and collider_bottom >= tile_top then
					for x_tiled=1, #level.tilemap[y_tiled] do
					local tile_leftedge = (x_tiled - 1) * tilesize
					local tile_rightedge = ((x_tiled - 1) * tilesize) + tilesize - 1
					if collider_leftedge <= tile_rightedge and collider_rightedge >= tile_leftedge then
						for i=1, #level.tilemap[y_tiled][x_tiled] do
							local tile = tiles[level.tilemap[y_tiled][x_tiled][i]]
							tile.type = level.tilemap[y_tiled][x_tiled][i]
							tile.x = ((x_tiled - 1) * tilesize) + (tile.hitboxXoffset or 0)
							tile.y = ((y_tiled - 1) * tilesize) + (tile.hitboxYoffset or 0)
							tile.hmom = 0
							tile.vmom = 0
							tile.width = tile.hitboxwidth or tilesize
							tile.height = tile.hitboxheight or tilesize
							if mobtools.doOverlapCheck(collider, tile) then table.insert(collidees, tile) end
							--[=[
							if tiles[level.tilemap[y_tiled][x_tiled][i]].deathly then
								if math.abs((((y_tiled - 1) * tilesize) - self.y)) < self.height then
									if math.abs((((x_tiled - 1) * tilesize) - self.x)) < self.width then
										if not checkonly then
											self:die()
										end
									end
								end
							end
							--]=]
						end
					end
				end
			end
		end
	end
	for i=1, #level.objects do
		obj = level.objects[i]
		if mobtools.doOverlapCheck(collider, obj) then table.insert(collidees, obj) end
	end
	return collidees
end

function mobtools.doOverlapCheck(collider, collidee)
	--this is simpler than docollisioncheck because we don't need a collision direction or suggested position, just whether or not the -er and -ee overlap
	local collider_rightedge = collider.x + collider.width - 1
	local collider_leftedge = collider.x
	local collidee_rightedge = collidee.x + collidee.width - 1
	local collidee_leftedge = collidee.x
	local collider_bottom = collider.y + collider.height - 1
	local collider_top = collider.y
	local collidee_bottom = collidee.y + collidee.height - 1
	local collidee_top = collidee.y
	if collider_top <= collidee_bottom and collider_bottom >= collidee_top then
		if collider_leftedge <= collidee_rightedge and collider_rightedge >= collidee_leftedge then
			if collidee.mask == nil and collider.mask == nil then
				return true
			elseif (collidee.mask and not collider.mask) or (collider.mask and not collidee.mask) then
				local collider = collider
				local collidee = collidee
				if not collidee.mask then
					collider, collidee = collidee, collider
					collider_top, collidee_top = collidee_top, collider_top
					collider_bottom, collidee_bottom = collidee_bottom, collider_bottom
					collider_leftedge, collidee_leftedge = collidee_leftedge, collider_leftedge
					collider_rightedge, collidee_rightedge = collidee_rightedge, collider_rightedge
				end
				local y_min = (math.floor(collider_top) - math.floor(collidee_top)) + 1
				local y_max = (math.floor(collider_bottom) - math.floor(collidee_top)) + 1
				local x_max = (math.floor(collider_rightedge) - math.floor(collidee_leftedge)) + 1
				local x_min = (math.floor(collider_leftedge) - math.floor(collidee_leftedge)) + 1
				if y_min < 1 then y_min = 1 end
				if y_max > collidee.height then y_max = collidee.height end
				if x_min < 1 then x_min = 1 end
				if x_max > collidee.width then x_max = collidee.width end
				local y_mask = y_min --for the longest time this was y_max for some reason and it caused really weird collision bugs since only one row of the mask ever got scanned
				local x_mask = x_min
				while y_mask <= y_max do
					if collidee.mask[y_mask] == nil then
						print(y_min, y_mask, y_max)
					elseif collidee.mask[y_mask][x_mask] == nil then
						print(x_min, x_mask, x_max)
					end
					if collidee.mask[y_mask][x_mask] then
						return true
					end
					x_mask = x_mask + 1
					if x_mask > x_max then
						x_mask = x_min
						y_mask = y_mask + 1
					end
				end
			else
				--two masked objects checking if they overlap isn't supported yet
			end
		end
	end
	return false
end

function mobtools.doPastEdgeScan(collider, dir, mustalign, level)
	--unfinished. should ideally be checking masks at some point
	level = level or collider.level
	local collidees = {}
	for i=1, #level.objects do
		obj = level.objects[i]
		if mobtools.doPastEdgeCheck(collider, obj, dir, mustalign) then table.insert(collidees, obj) end
	end
	return collidees
end

function mobtools.doPastEdgeCheck(collider, collidee, dir, mustalign)
	local collider_rightedge = collider.x + collider.width - 1
	local collider_leftedge = collider.x
	local collidee_rightedge = collidee.x + collidee.width - 1
	local collidee_leftedge = collidee.x
	local collider_bottom = collider.y + collider.height - 1
	local collider_top = collider.y
	local collidee_bottom = collidee.y + collidee.height - 1
	local collidee_top = collidee.y
	local horizontallyaligned = collider_top <= collidee_bottom and collider_bottom >= collidee_top
	local verticallyaligned   = collider_leftedge <= collidee_rightedge and collider_rightedge >= collidee_leftedge
		if dir == "left"  then
			local condition1 = collidee_rightedge < collider_leftedge
			local condition2 = (not mustalign) or horizontallyaligned
			return condition1 and condition2
	elseif dir == "right" then
			local condition1 = collidee_leftedge > collider_rightedge
			local condition2 = (not mustalign) or horizontallyaligned
			return condition1 and condition2
	elseif dir == "up"    then
			local condition1 = collidee_bottom < collider_top
			local condition2 = (not mustalign) or verticallyaligned
			return condition1 and condition2
	elseif dir == "down"  then
			local condition1 = collidee_top > collider_bottom
			local condition2 = (not mustalign) or verticallyaligned
			return condition1 and condition2
	else error("invalid direction given for pastedgescan", 3) end
	return false
end