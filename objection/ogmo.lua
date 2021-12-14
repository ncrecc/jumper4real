-- to friggin do!
-- add coyote time
-- add walljump coyote time (thx xelu)
ogmo = class:new()


--[[
  **QUADS**
1. idle
2. idle, blinking
3. ducking
4. ducking, blinking
5-8. walking right
9-12.walking left
13-16. jumping
17-20. jumping right
21-24. jumping left
25. falling
26. falling right
27. falling left
28. looking up
29. ded
30. ded right
31. ded left
32. looking up, blinking
33. gost's block
-]]

ogmo.quads = {}
for i=0, 32 do --32 instead of 31. yes, we're starting at 0 and for loop syntax is inclusive in lua, so starting at 0 and iterating to 32 means we get 33 elements, but there is a 33rd element! gost's block, an object that acts like an additional ogmo and causes another ogmo to die when it dies
	table.insert(ogmo.quads, love.graphics.newQuad((i % 4) * 16, math.floor(i / 4) * 16, 16, 16, 64, 160))
end

function ogmo.editorimg(options)
	gost = false
	for i=1, #options do
		if options[i] == "gost" then
			gost = true
		end
	end
	if not gost then return graphics:load("ogmo")
	else return graphics:load("gostsblock") end
end

function ogmo:init(x, y, width, height, gost)
	self.type = "ogmo"
	self.keyreactions = {
		["up"] = true
	}
	self.x = x
	self.y = y
	self.width = width
	self.height = height
	self.id = nil --just ego and superego here folks
	self.gost = gost
	self.solid = true
	if self.gost and self.solid then self.solid = false end
	self.alive = true
	self.x_clamped = x
	self.y_clamped = y
	self.hmom = 0
	self.hmom_min = -999
	self.hmom_max = 999
	self.maxspeed = 6 --natural cap on speed
	self.vmom = 0
	self.vmom_min = -999
	self.vmom_max = 999
	self.acceleration = 0.2 --self.acceleration is added to ogmo's speed while he's holding an arrow key in the direction he's moving
	self.friction = 0.6 --self.friction is a weird opposite of self.acceleration: it's subtracted from ogmo's speed while his speed is greater than 0 but he's not holding an arrow key in the direction he's moving
	--friction refers to how long it should take ogmo to come to a stop, and has no effect on his speed while he's moving, which probably means "friction" and "acceleration" are weird misnomers here
	--this does mean that jumper 2-esque ice has to be implemented 
	self.gravity = 0.2
	self.defaultjumps = 2
	self.jumps = self.defaultjumps - 1 --in case ogmo spawns in midair
	self.jumpheight = 6
	self.jumpzaniness = 0 --the extent to which jumps should inherit current velocity, meaning doublejumping twice in a row lets you jump way higher. i thought i was so clever when i came up with this
	self.walljumpheight = 5
	self.walljumpspeed = 6
	self.tempfriction = nil --temp friction results from doing a walljump and is lower than normal friction; it also disallows you from walljumping back onto the same wall quick enough to get further up
	self.oldtempfriction = nil
	self.walljumptempfriction = 0.05 --what your tempfriction should be after doing a walljump
	self.tempfrictiontimer = 0
	self.walljumptempfrictiontimer = 24
	self.walljumptempfrictionphaseouttimer = 12 --todo: make separate tempfrictionphaseouttimer an actual thing
	self.grounded = false
	self.walled = "none"
	self.justjumped = false
	
	--QUAD TIME
	self.currentquad = 1
end

function ogmo:setup(x, y, options)
	gost = false
	for i=1, #options do
		if options[i] == "gost" then
			gost = true
		end
	end
	if not gost then game.playeramt = game.playeramt + 1 end
	return ogmo:new(x, y, tilesize, tilesize, gost)
end

function ogmo:update(dt)
	if self.alive then self:movement(dt) end
end

function ogmo:movement(dt)
	--can't remember precisely where but there's a lot of places here that negate maddy thorson's recurrent antipattern of being counteracting the player moving against their current momentum but forgetting to apply the same hasrhness to the player not moving at all while they have momentum. this results in, among other things, neutraljumping being possible in celeste
	if self.tempfrictiontimer ~= 0 and self.tempfriction == nil then
		self.tempfrictiontimer = 0
	end
	if self.tempfrictiontimer > 0 then
		self.tempfrictiontimer = self.tempfrictiontimer - 1
	end
	
	if self.tempfriction ~= nil and self.tempfrictiontimer == 0 then 
		self.oldtempfriction = self.tempfriction
		self.tempfriction = self.tempfriction + (math.abs(self.friction - self.oldtempfriction) / self.walljumptempfrictionphaseouttimer) --gradually phase out the temp friction
	end
	
	if self.tempfriction == self.friction then
		self.oldtempfriction = nil
		self.tempfriction = nil
	end
	if not(love.keyboard.isDown("right") and love.keyboard.isDown("left")) then
		if love.keyboard.isDown("right") and self.hmom < self.maxspeed then
			
			oldhmom = self.hmom
			self.hmom = self.hmom + self.acceleration
			if oldhmom * self.hmom < 0 then
				self.tempfriction = nil
			end
		elseif love.keyboard.isDown("left") and (-1 * self.hmom) < self.maxspeed then
			oldhmom = self.hmom
			self.hmom = self.hmom - self.acceleration
			if oldhmom * self.hmom < 0 then
				self.tempfriction = nil
			end
		end
	end
	
	if not love.keyboard.isDown("right") and self.hmom > 0 then
		if self.tempfriction ~= nil then
			self.hmom = self.hmom - self.tempfriction
		else
			self.hmom = self.hmom - self.friction
		end
		if self.hmom <= 0 then
			self.tempfriction = nil
			self.hmom = 0
		end
	elseif not love.keyboard.isDown("left") and self.hmom < 0 then
		if self.tempfriction ~= nil then
			self.hmom = self.hmom + self.tempfriction
		else
			self.hmom = self.hmom + self.friction
		end
		if self.hmom >= 0 then
			self.tempfriction = nil
			self.hmom = 0
		end
	end
	
	if self.hmom > self.hmom_max then
		self.hmom = self.hmom_max
	elseif self.hmom < self.hmom_min then
		self.hmom = self.hmom_min
	end
	
	self.vmom = self.vmom + self.gravity
	
	if self.vmom > self.vmom_max then
		self.vmom = self.vmom_max
	elseif self.vmom < self.vmom_min then
		self.vmom = self.vmom_min
	end
	
	applyhfirst = true
	if math.abs(self.vmom) > math.abs(self.hmom) then
		applyhfirst = false
	end
	
	oldgroundedtemp = self.grounded
	
	if applyhfirst then
		self.walled = self:horiCollision()
		self.x = self.x + self.hmom
		self.grounded = self:vertCollision()
		self.y = self.y + self.vmom
	else
		self.grounded = self:vertCollision()
		self.y = self.y + self.vmom
		self.walled = self:horiCollision()
		self.x = self.x + self.hmom
	end
	self:postmoveCollision()
	
	if self.justjumped == false and oldgroundedtemp == true and self.grounded == false then
		self.jumps = self.jumps - 1
	end
	
	self.justjumped = false
	
	--self.x = self.x + self.hmom
	--self.y = self.y + self.vmom
	
	self.x_clamped = math.floor(self.x + .5)
	self.y_clamped = math.floor(self.y + .5)
	
	--if math.abs(self.hmom) < 0.1 then
	if self.hmom == 0 then
		self.x = self.x_clamped
	end
	if self.vmom == 0 then
		self.y = self.y_clamped
	end
	
	if self.y > 512 then self:die() end
end

function ogmo:keypressed(key)
	if key == "up" then self:jump() end
end

function ogmo:jump()
	if self.grounded == false and self.walled ~= "none" then
		self.vmom = (self.vmom * self.jumpzaniness) - self.walljumpheight
		if self.walled == "left" then
			self.hmom = self.walljumpspeed
			self.tempfriction = self.walljumptempfriction
			self.tempfrictiontimer = self.walljumptempfrictiontimer
		elseif self.walled == "right" then
			self.hmom = (-1 * self.walljumpspeed)
			self.tempfriction = self.walljumptempfriction
			self.tempfrictiontimer = self.walljumptempfrictiontimer
		end
		if not self.gost then audio.playsfx("ogmo jump") end
		self.justjumped = true
	elseif self.jumps > 0 then
		self.vmom = (self.vmom * self.jumpzaniness) - self.jumpheight
		self.jumps = self.jumps - 1
		if not self.gost then audio.playsfx("ogmo jump") end
		self.justjumped = true
	end
end

function ogmo:die(vanish) --"vanish" arg is for if you are gost's block and you've been touched by an ogmo
	if not self.alive then print ("todo: you died, but you're already dead? figure this out. postmovecollision is being called after you're already dead") else
		if vanish then
			audio.playsfx("gostblock vanish")
			print("gost's block vanished")
		end
		if not self.gost then audio.playsfx("ogmo die") end
		self.alive = false
		self.solid = false
		if not self.gost then
			game.liveplayeramt = game.liveplayeramt - 1
			if game.liveplayeramt > 0 then print("ogmo is dead! players remaining: " .. game.liveplayeramt) end
		elseif not vanish then
			for i=1, #game.loadedobjects do
				obj = game.loadedobjects[i]
				if obj.type == "ogmo" and not obj.gost then
					obj:die()
					break
				end
			end
		end
	end
end

function ogmo:draw()
	if self.alive then
		if not self.gost then love.graphics.draw(graphics:load("ogmo"), self.x_clamped, self.y_clamped)
		else love.graphics.draw(graphics:load("gostsblock"), self.x_clamped, self.y_clamped) end
	end
	--if game.playeramt == 1 then love.graphics.print(self.tempfrictiontimer .. "", 400) end
end

function ogmo:horiCollision(checkonly)
--90% of this and vertcollision are hot garbage and make no sense but work correctly if all objects/tiles are the same height and width as ogmo
	checkonly = checkonly or false
	for y_tiled=1, #game.tilemap do
		for x_tiled=1, #game.tilemap[y_tiled] do
			for i=1, #game.tilemap[y_tiled][x_tiled] do
				if tiles[game.tilemap[y_tiled][x_tiled][i]].solid and (math.abs((((y_tiled - 1) * tilesize) - self.y)) < self.height) then
					if (self.hmom > 0) and (((x_tiled - 1) * tilesize) > (self.x + self.width - 1)) then --checks that ogmo is heading right and the left surface of the tile is to the right of the right surface of ogmo
						if (math.abs(((x_tiled - 1) * tilesize) - (self.x + self.width - 1)) - 1 <= (math.abs(self.hmom))) then --checks that absolute distance between left surface of tile and right surface of ogmo is less than ogmo's absolute momentum.
							if not checkonly then
								self.x = ((x_tiled - 1) * tilesize) - self.width
								self.hmom = 0
								self.tempfriction = nil
							end
							return "right"
						end
					end
					if (self.hmom < 0) and ((((x_tiled - 1) * tilesize) + self.width - 1) < self.x) then
						if (math.abs((((x_tiled - 1) * tilesize) + self.width - 1) - self.x) - 1 <= (math.abs(self.hmom))) then
							if not checkonly then
								self.x = ((x_tiled - 1) * tilesize) + self.width
								self.hmom = 0
								self.tempfriction = nil
							end
							return "left"
						end
					end
				end
			end
		end
	end
	for i=1, #game.loadedobjects do
		obj = game.loadedobjects[i]
		--gost's block shouldn't collide with ogmos
		if not (self.gost and obj.type == "ogmo") then
			if obj.solid and (math.abs(((obj.y) - self.y)) < self.height) then
				if (self.hmom > 0) and ((obj.x) > (self.x + self.width - 1)) then --checks that ogmo is heading right and the left surface of the object is to the right of the right surface of ogmo
					if (math.abs((obj.x) - (self.x + self.width - 1)) - 1 <= (math.abs(self.hmom))) then --checks that absolute distance between left surface of object and right surface of ogmo is less than ogmo's absolute momentum.
						if not checkonly then
							self.x = obj.x - self.width
							self.hmom = 0
							self.tempfriction = nil
						end
						return "right"
					end
				end
				if (self.hmom < 0) and ((obj.x) + obj.width - 1) < self.x then
					if (math.abs(((obj.x) + obj.width - 1) - self.x) - 1 <= (math.abs(self.hmom))) then
						if not checkonly then
							self.x = obj.x + obj.width
							self.hmom = 0
							self.tempfriction = nil
						end
						return "left"
					end
				end
			end
		end
	end
	return "none"
end

function ogmo:vertCollision(checkonly)
	checkonly = checkonly or false
	for y_tiled=1, #game.tilemap do
		for x_tiled=1, #game.tilemap[y_tiled] do
			for i=1, #game.tilemap[y_tiled][x_tiled] do
				if tiles[game.tilemap[y_tiled][x_tiled][i]].solid and (math.abs((((x_tiled - 1) * tilesize) - self.x)) < self.width) then
					if (self.vmom > 0) and (((y_tiled - 1) * tilesize) > (self.y + self.height - 1)) then
						if (math.abs(((y_tiled - 1) * tilesize) - (self.y + self.height - 1)) - 1 <= (math.abs(self.vmom))) then
							if not checkonly then
								self.y = ((y_tiled - 1) * tilesize) - self.height
								self.vmom = 0
								self.jumps = self.defaultjumps
								self.tempfriction = nil
							end
							return true
						end
					end
					if (self.vmom < 0) and ((((y_tiled - 1) * tilesize) + self.height - 1) < self.y) then
						if (math.abs((((y_tiled - 1) * tilesize) + self.height - 1) - self.y) - 1 <= (math.abs(self.vmom))) then
							if not checkonly then
								self.y = ((y_tiled - 1) * tilesize) + self.height
								self.vmom = 0
							end
							return false
						end
					end
				end
			end
		end
	end
	for i=1, #game.loadedobjects do
		obj = game.loadedobjects[i]
		--gost's block shouldn't collide with non-gost ogmos
		if not (self.gost and (obj.type == "ogmo" and not obj.gost)) then
			if obj.solid and (math.abs(((obj.x) - self.x)) < self.width) then
				if (self.vmom > 0) and ((obj.y) > (self.y + self.height - 1)) then
					if (math.abs((obj.y) - (self.y + self.height - 1)) - 1 <= (math.abs(self.vmom))) then
						if not checkonly then
							self.y = obj.y - self.height
							self.vmom = 0
							self.jumps = self.defaultjumps
							self.tempfriction = nil
						end
						return true
					end
				end
				if (self.vmom < 0) and ((obj.y) + self.height - 1) < self.y then
					if (math.abs(((obj.y) + obj.height - 1) - self.y) - 1 <= (math.abs(self.vmom))) then
						if not checkonly then
							self.y = obj.y + self.height
							self.vmom = 0
						end
						return false
					end
				end
			end
		end
	end
	return false
end

function ogmo:postmoveCollision(checkonly)
	checkonly = checkonly or false
	for y_tiled=1, #game.tilemap do
		for x_tiled=1, #game.tilemap[y_tiled] do
			for i=1, #game.tilemap[y_tiled][x_tiled] do
				if tiles[game.tilemap[y_tiled][x_tiled][i]].deathly then
				--	if(self.y > ((y - 1) * tilesize)) and (self.y < (((y - 1) * tilesize) + tilesize - 1)) then
				--		if(self.x > ((x - 1) * tilesize)) and (self.x < (((x - 1) * tilesize) + tilesize - 1)) then
					if math.abs((((y_tiled - 1) * tilesize) - self.y)) < self.height then
						if math.abs((((x_tiled - 1) * tilesize) - self.x)) < self.width then
							if not checkonly then
								self:die()
							end
						end
					end
				end
			end
		end
	end
	for i=1, #game.loadedobjects do
		obj = game.loadedobjects[i]
		if obj.deathly or (self.gost and obj.type == "ogmo" and not obj.gost) then
			--if(self.y > (obj.y)) and (self.y < (obj.y + obj.height - 1)) then
			--	if(self.x > (obj.x)) and (self.x < (obj.x + obj.width - 1)) then
			if math.abs(((obj.y + self.vmom) - (self.y + self.vmom))) < self.height then --adding vmom/hmom is a quick lazy way to check where the object will be next update. could potentially cause some collision jankiness with objects that are moving into walls but are yet to have their momentum canceled - and could cause unexpected deaths with objects that are going so fast their projected position goes past a wall, or with deadly objects behind a very thin wall. well, whatever. probably won't have to deal with those situations any time soon.
				if math.abs(((obj.x + self.hmom) - (self.x + self.hmom))) < self.width then
					if not checkonly then
						vanish = false
						if (self.gost) and (obj.type == "ogmo") then vanish = true end
						self:die(vanish)
					end
				end
			end
		end
	end
end

return ogmo