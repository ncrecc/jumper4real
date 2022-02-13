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
ogmo.quaddefs = {
	"idle",
	"idleblink",
	"duck",
	"duckblink",
	"walkright1",
	"walkright2",
	"walkright3",
	"walkright4",
	"walkleft1",
	"walkleft2",
	"walkleft3",
	"walkleft4",
	"jump1",
	"jump2",
	"jump3",
	"jump4",
	"jumpright1",
	"jumpright2",
	"jumpright3",
	"jumpright4",
	"jumpleft1",
	"jumpleft2",
	"jumpleft3",
	"jumpleft4",
	"fall",
	"fallright",
	"fallleft",
	"lookup",
	"ded",
	"dedright",
	"dedleft",
	"lookupblink",
	"gost"
}
ogmo.canblinkquads = {
	["idle"] = "idleblink",
	["duck"] = "duckblink",
	["lookup"] = "lookupblink"
} 
ogmo.blinkingquads = {
	["idleblink"] = "idle",
	["duckblink"] = "duck",
	["lookupblink"] = "lookup"
} 

for i=0, 32 do --32 instead of 31. yes, we're starting at 0 and for loop syntax is inclusive in lua, so starting at 0 and iterating to 32 means we get 33 elements, but there is a 33rd element! gost's block, an object that acts like an additional ogmo and causes another ogmo to die when it dies
	--table.insert(ogmo.quads, love.graphics.newQuad((i % 4) * 16, math.floor(i / 4) * 16, 16, 16, 64, 160))
	ogmo.quads[ogmo.quaddefs[i + 1]] = love.graphics.newQuad((i % 4) * 16, math.floor(i / 4) * 16, 16, 16, 64, 160)
end

function ogmo.editordraw(x, y, options)
	local gost = false
	for i=1, #options do
		if options[i] == "gost" then
			gost = true
		end
	end
	local quadtodraw = "idle"
	if gost then quadtodraw = "gost" end
	love.graphics.draw(graphics.load("ogmos/" .. game.ogmoskin), ogmo.quads[quadtodraw], x, y)
end

function ogmo:init(x, y, width, height, gost, playerno, edge, magicvalue)
	self.edge = edge
	self.magicvalue = magicvalue
	self.initializationdone = false
	self.cutscene_firstfreemovement = false --this refers to the first frame after initialization if you're in a cutscene movement. this is a kludge that gets checked so that you can't jump while you're out of bounds and hit your face on the outer wall, or move onto the ceiling if you start the level while falling. this isn't necessary for starting the level jumping since in that case your vertical momentum 
	
	self.type = "ogmo"
	self.player = true
	self.playerno = playerno or 1
	self.x = x
	self.y = y
	self.width = width or tilesize
	self.height = height or tilesize
	self.id = nil --just ego and superego here folks
	self.gost = gost
	self.solid = true
	--if self.gost and self.solid then self.solid = false end
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
	self.jumpforce = 6
	self.skidjumpextraforce = 2
	self.jumpzaniness = 0 --the extent to which jumps should inherit current velocity, meaning doublejumping twice in a row lets you jump way higher. i thought i was so clever when i came up with this
	self.walljumpforce = 5
	self.walljumpspeed = 6
	self.tempfriction = nil --temp friction results from doing a walljump and is lower than normal friction; it's main purpose is to disallow you from walljumping back onto the same wall quick enough to get further up
	self.oldtempfriction = nil
	self.walljumptempfriction = 0.05 --what your tempfriction should be after doing a walljump
	self.tempfrictiontimer = 0
	self.walljumptempfrictionframes = 24
	self.tempfrictionphaseouttimer = 12
	self.cutscenemovement = nil --"right", "left", "up", or "down"
	self.verticaled = "none"
	self.verticaledby = {}
	self.grounded = false
	self.walled = "none"
	self.walledby = {}
	self.overlaps = {}
	self.overlappingwin = false
	self.collisioncondition = function(self, collidee)
		if collidee == "levelborder" then
			if (not not self.cutscenemovement) or ((not self.gost) and self.overlappingwin) then return false end
		end
		if collidee.type == "ogmo" and ((not not collidee.gost) ~= (not not self.gost)) then return false end
		return true
	end
	self.skidding = "none"
	self.skiddingframes = 12
	self.skiddingtimer = 0
	self.skiddingspeedleniency = 0 --formerly 0.5. alt solution to a problem that startskiddingtimer solved - adding leniency to allowing the player to start skidding after they reach max speed. unlike startskiddingtimer, this solution was implemented in a way that doesn't allow players to skid by letting go of the direction they're moving in and then pressing the other direction (only worked with an interim of holding both keys at once)
	--this could also be good for just... plain leniency
	self.startskiddingframes = 4
	self.startskiddingtimer = 0
	self.ducking = false
	self.lookingup = false
	
	self.extraverticalbits = {}
	self.extrahorizontalbits = {}
	self.justjumped = false
	
	self.gfxoffsets = {0, 0}
	
	--QUAD TIME
	self.currentquad = "idle"
	
	self.animtimer = 128
	self.animframestoblink = 128
	self.animframestounblink = 8
	self.animframestostep = 6
	self.animframestotumble = 3
end

function ogmo:setup(x, y, options, level, edge, magicvalue)
	--[[
	if (not magicvalue) and level.entrance == 0 then magicvalue = 0 end
	if (not magicvalue) then magicvalue = 1 end
	]] --uncommenting this, and removing 'type(magicvalue) == "number"' from the next line, makes it so un-numbered ogmos will only show when level.entrance is 0 or 1
	if type(magicvalue) == "number" and level.entrance ~= magicvalue then return nil end
	gost = false
	for i=1, #options do
		if options[i] == "gost" then
			gost = true
		end
	end
	if not gost then level.playeramt = level.playeramt + 1 end
	if edge and not gost then
		if edge == "left" then
			x = x - 16
		elseif edge == "right" then
			x = x + 16
		elseif edge == "up" then
			y = y - 16
		elseif edge == "down" then
			y = y + 16
		end
	end
	return ogmo:new(x, y, tilesize, tilesize, gost, 1, edge, magicvalue)
end

function ogmo:keyDown(key, ignorecutscenelogic)
	if ignorecutscenelogic then
		return love.keyboard.isDown(controls["P" .. self.playerno .. key:upper()])
	else
		if     key == "right" and self.cutscenemovement == "right" then return true
		elseif key == "left" and self.cutscenemovement == "left" then return true
		elseif self.cutscenemovement == "right" or self.cutscenemovement == "left" then return false
		elseif self.cutscene_firstfreemovement and (self.cutscenemovement == "down" or self.cutscenemovement == "up") then return false end
		return love.keyboard.isDown(controls["P" .. self.playerno .. key:upper()])
	end
end

function ogmo:update(dt)
	if not self.level then print("OGMO SEZ: I'M IN A NIL LEVEL SO I'M GONNA BE ANGRY ABOUT IT AND FLOOD THE CONSOLE!") end
	if self.alive then
		self:movement(dt)
		
		--major, game-breaking glitch in the following code: if you time your ducks or unducks frame perfectly, you can avoid blinking ever while idling/ducking, thus making you a monster depriving ogmo of sleep
		if self.animtimer > 0 then self.animtimer = self.animtimer - 1 end
		
		if self.vmom < 0 then
			if string.sub(self.currentquad, 1, 4) ~= "jump" then
				self.currentquad = "jump1"
				self.animtimer = self.animframestotumble
			end
			jumpnum = tonumber(string.sub(self.currentquad, -1, -1))
			if not (self:keyDown("right") and self:keyDown("left")) then
				if self:keyDown("right") then self.currentquad = "jumpright" .. jumpnum
				elseif self:keyDown("left") then self.currentquad = "jumpleft" .. jumpnum end
			end
			if self.animtimer <= 0 and not(jumpnum == 1 and self.vmom > -0.5) then
				local jump = string.sub(self.currentquad, 1, -2)
				jumpnum = jumpnum + 1
				if jumpnum > 4 then jumpnum = 1 end
				self.currentquad = jump .. tostring(jumpnum)
				self.animtimer = self.animframestotumble
			end
		elseif self.vmom > 0 then --note: does not check for whether ogmo can actually fall by a full pixel this frame
			self.currentquad = "fall"
			if not (self:keyDown("right") and self:keyDown("left")) then
				if self:keyDown("right") then self.currentquad = "fallright"
				elseif self:keyDown("left") then self.currentquad = "fallleft" end
			end
		else
			if self.ducking and string.sub(self.currentquad, 1, 4) ~= "duck" then
				if not (self.canblinkquads[self.currentquad] or self.blinkingquads[self.currentquad]) then
					self.animtimer = self.animframestoblink
					self.currentquad = "duck"
				else
					if self.canblinkquads[self.currentquad] then self.currentquad = "duck"
					else self.currentquad = "duckblink" end
				end
				
			end
			
			if not self.ducking and not (self:keyDown("right") and self:keyDown("left")) then
				if self:keyDown("right") and string.sub(self.currentquad, 1, -2) ~= "walkright" then
					self.currentquad = "walkright1"
					self.animtimer = self.animframestostep
				elseif self:keyDown("left") and string.sub(self.currentquad, 1, -2) ~= "walkleft" then
					self.currentquad = "walkleft1"
					self.animtimer = self.animframestostep
				end
			end
			
			if string.sub(self.currentquad, 1, 4) ~= "idle" and string.sub(self.currentquad, 1, 6) ~= "lookup" and not self.ducking and ((self:keyDown("right") and self:keyDown("left")) or not (self:keyDown("right") or self:keyDown("left"))) then
				if not (self.canblinkquads[self.currentquad] or self.blinkingquads[self.currentquad]) then
					self.animtimer = self.animframestoblink
					self.currentquad = "idle"
				else
					if self.canblinkquads[self.currentquad] then self.currentquad = "idle"
					else self.currentquad = "idleblink" end
				end
			end
			
			if string.sub(self.currentquad, 1, 4) == "idle" and self.lookingup then 
				if self.blinkingquads[self.currentquad] then self.currentquad = "lookupblink"
				elseif self.canblinkquads[self.currentquad] then self.currentquad = "lookup" end
			elseif string.sub(self.currentquad, 1, 6) == "lookup" and not self.lookingup then 
				if self.blinkingquads[self.currentquad] then self.currentquad = "idleblink"
				elseif self.canblinkquads[self.currentquad] then self.currentquad = "idle" end
			end
			
			if self.animtimer <= 0 then
				if self.canblinkquads[self.currentquad] then
					self.currentquad = self.canblinkquads[self.currentquad] --blink
					self.animtimer = self.animframestounblink
				elseif self.blinkingquads[self.currentquad] then
					self.currentquad = self.blinkingquads[self.currentquad] --unblink
					self.animtimer = self.animframestoblink
				elseif string.sub(self.currentquad, 1, -2) == "walkright" or string.sub(self.currentquad, 1, -2) == "walkleft" then
					local walk = string.sub(self.currentquad, 1, -2)
					local walknum = tonumber(string.sub(self.currentquad, -1, -1))
					walknum = walknum + 1
					if walknum > 4 then walknum = 1 end
					self.currentquad = walk .. tostring(walknum)
					self.animtimer = self.animframestostep
				end
			end
		end
	end
end

function ogmo:notWalkingRight()
	if ((self.ducking) or
		(not self:keyDown("right")) or
		(self:keyDown("left") and self:keyDown("right")))
	then
		return true
	end
	return false
end

function ogmo:notWalkingLeft()
	if ((self.ducking) or
		(not self:keyDown("left")) or
		(self:keyDown("left") and self:keyDown("right")))
	then
		return true
	end
	return false
end

function ogmo:movement(dt)
	--can't remember precisely where but there's a lot of places here that negate maddy thorson's recurrent antipattern of counteracting the player moving against their current momentum but forgetting to apply the same harshness to the player not moving at all while they have momentum. this results in, among other things, neutraljumping being possible in celeste and jumper 2
	if self.cutscenemovement == "up" and not self.level.options.bottombordersolid then
		self.cutscenemovement = nil --if you jump into the level, you should only be counted as doing cutscenemovement for the minimum amount of time for things to work as they should
	end
	
	self.cutscene_firstfreemovement = false
	if not self.initializationdone then
		if self.edge == "left" then
			self.cutscenemovement = "right"
			self.cutscene_firstfreemovement = true
		elseif self.edge == "right" then
			self.cutscenemovement = "left"
			self.cutscene_firstfreemovement = true
		elseif self.edge == "up" then
			self.cutscenemovement = "down"
			self.cutscene_firstfreemovement = true
		elseif self.edge == "down" then
			self.cutscenemovement = "up"
			self.vmom = -1 * self.jumpforce
		end
		self.initializationdone = true
	end
	
	if self.cutscenemovement and self.x >= 0 and self.x + self.width <= self.level.width and self.y >= 0 and self.y + self.height <= self.level.height then
		self.cutscenemovement = nil
	end
	
	if self.tempfrictiontimer ~= 0 and self.tempfriction == nil then
		self.tempfrictiontimer = 0
	end
	if self.tempfrictiontimer > 0 then
		self.tempfrictiontimer = self.tempfrictiontimer - 1
	end
	
	self.grounded = (self.verticaled == "down")
	
	if self.verticaled ~= "down" then
		self.skiddingtimer = 0
		self.startskiddingtimer = 0
		self.skidding = "none"
	end
	if self.skiddingtimer > 0 then
		self.skiddingtimer = self.skiddingtimer - 1
	end
	if self.skiddingtimer == 0 then
		self.skidding = "none"
	end
	
	if self.startskiddingtimer > 0 then
		self.startskiddingtimer = self.startskiddingtimer - 1
	end
	if self.tempfriction ~= nil and self.tempfrictiontimer == 0 then 
		self.oldtempfriction = self.tempfriction
		self.tempfriction = self.tempfriction + (math.abs(self.friction - self.oldtempfriction) / self.tempfrictionphaseouttimer) --gradually phase out the temp friction
	end
	
	if self.tempfriction == self.friction then
		self.oldtempfriction = nil
		self.tempfriction = nil
	end
	
	if math.abs(self.hmom) >= self.maxspeed - self.skiddingspeedleniency then
		self.startskiddingtimer = self.startskiddingframes
	end
	
	if not self.ducking then
		if self.verticaled == "down" then
			if self:keyDown("right") and self.hmom < 0 and self.startskiddingtimer > 0 then
				self.skiddingtimer = self.skiddingframes
				self.skidding = "right"
			end
			if self:keyDown("left") and self.hmom > 0 and self.startskiddingtimer > 0 then
				self.skiddingtimer = self.skiddingframes
				self.skidding = "left"
			end
		end
		if not (self:keyDown("right") and self:keyDown("left")) then
			if self:keyDown("right") and self.hmom < self.maxspeed then
				local oldhmom = self.hmom
				local accelerationcapped = self.acceleration
				if math.abs(self.hmom) + accelerationcapped > self.maxspeed then
					local accelerationspillover = (math.abs(self.hmom) + accelerationcapped) - self.maxspeed
					accelerationcapped = accelerationcapped - accelerationspillover
					if accelerationcapped < 0 then accelerationcapped = 0 end --don't reset player's speed if they try to move while going faster than maxspeed (due to external circumstances)
				end
				self.hmom = self.hmom + accelerationcapped
				if oldhmom * self.hmom < 0 then
					self.tempfriction = nil
				end
			elseif self:keyDown("left") and (-1 * self.hmom) < self.maxspeed then
				local oldhmom = self.hmom
				local accelerationcapped = self.acceleration
				if math.abs(self.hmom) + accelerationcapped > self.maxspeed then
					local accelerationspillover = (math.abs(self.hmom) + accelerationcapped) - self.maxspeed
					accelerationcapped = accelerationcapped - accelerationspillover
					if accelerationcapped < 0 then accelerationcapped = 0 end --don't reset player's speed if they try to move while going faster than maxspeed (due to external circumstances)
				end
				self.hmom = self.hmom - accelerationcapped
				if oldhmom * self.hmom < 0 then
					self.tempfriction = nil
				end
			end
		end
	end
	
	if (self:notWalkingRight() and self.hmom > 0) or self.hmom > self.maxspeed then --apply friction if player is not moving OR if player is going faster than their normally attainable speed
		if self:keyDown("right") and self.hmom > self.maxspeed and (self.hmom - self.friction) <= self.maxspeed then
			self.hmom = self.maxspeed
		else
			self.hmom = self.hmom - (self.tempfriction or self.friction)
		end
		
		if self.hmom <= 0 then
			self.tempfriction = nil
			self.hmom = 0
		end
	elseif (self:notWalkingLeft() and self.hmom < 0) or (self.hmom * -1) > self.maxspeed then --ditto
		if self:keyDown("right") and self.hmom > self.maxspeed and (self.hmom - self.friction) <= self.maxspeed then
			self.hmom = self.maxspeed
		else
			self.hmom = self.hmom + (self.tempfriction or self.friction)
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
	
	if not self.dont_move_vert_on_first_update_of_horiz_edge_entry then
		self.vmom = self.vmom + self.gravity
	end
	
	if self.vmom > self.vmom_max then
		self.vmom = self.vmom_max
	elseif self.vmom < self.vmom_min then
		self.vmom = self.vmom_min
	end
	
	local applyhfirst = true
	if math.abs(self.vmom) > math.abs(self.hmom) then
		applyhfirst = false
	end
	
	local oldverticaledtemp = self.verticaled
	
	local collisionfunctions = {
		horizontal = function()
			local newposition
			local newwalled
			local newwalledby
			
			newwalled, newposition, newwalledby = mobtools.doCollisionScan("horizontal", self)
			
			self.walled = newwalled
			self.walledby = newwalledby
			
			if newposition == nil then
				self.x = self.x + self.hmom
			else
				local bounce = false
				for _,collider in ipairs(self.walledby) do
					if collider.bounce then
						bounce = true
						break
					end
				end
				if bounce or game.imrubber then --why do i keep nerd sniping myself into implementing will-never-be-used shit like rubber instead of the basics of jumper
					self.hmom = -self.hmom
					if math.abs(self.hmom) < 1 then self.hmom = 0 end --no subpixel bouncing
					local frictiondivisor = math.abs(self.hmom) * 2
					if frictiondivisor < 1 then frictiondivisor = 1 end
					self.tempfriction = self.friction / (frictiondivisor)
					self.tempfrictiontimer = self.walljumptempfrictionframes
				else self.hmom = 0 end
				self.x = newposition
				for _,collider in ipairs(self.walledby) do
					if collider.onCollide then
						collider:onCollide(self, self.walled)
					end
				end
				if bounce and self.hmom ~= 0 then self.walled = false; self.walledby = {} end
			end
		end,
		
		vertical = function()
			local newposition
			local newverticaled
			local newverticaledby
			
			newverticaled, newposition, newverticaledby = mobtools.doCollisionScan("vertical", self)
			
			self.verticaled = newverticaled
			self.verticaledby = newverticaledby
			
			if newposition == nil then
				self.y = self.y + self.vmom
			else
				local bounce = false
				for _,collider in ipairs(self.verticaledby) do
					if collider.bounce then
						bounce = true
						break
					end
				end
				if bounce or game.imrubber then
					self.vmom = -self.vmom
					if math.abs(self.vmom) < 1 then self.vmom = 0 end
				else self.vmom = 0 end
				self.y = newposition
				if self.verticaled == "down" and not (bounce and self.vmom ~= 0) then
					self.jumps = self.defaultjumps
					self.tempfriction = nil
				end
				for _,collider in ipairs(self.verticaledby) do
					if collider.onCollide then
						collider:onCollide(self, self.verticaled)
					end
				end
				if bounce and self.vmom ~= 0 then self.verticaled = false; self.verticaled = {} end
			end
		end
	}
	
	if applyhfirst then
		collisionfunctions.horizontal()
		collisionfunctions.vertical()
	else
		collisionfunctions.vertical()
		collisionfunctions.horizontal()
	end
	
	self.overlaps = mobtools.doOverlapScan(self)
	local juststoppedoverlappingwin = false
	if self.overlappingwin then
		juststoppedoverlappingwin = true
	end
	self.overlappingwin = false
	for _,obj in ipairs(self.overlaps) do --oops, this is a bit of a misnomer. this handles both objects AND tiles killing ogmo, because when collision processes a tile, it returns it formatted like an object.
		if(obj.deathly) then
			if not game.godmode then self:die() end
		elseif(obj.type == "ogmo" and not obj.gost and self.gost) then
			self:die(true)
		elseif obj.type == "win" then
			self.overlappingwin = true
			juststoppedoverlappingwin = false
		end
	end
	
	if self.justjumped == false and oldverticaledtemp == "down" and self.verticaled == "none" then
		self.jumps = self.jumps - 1
	end
	
	self.justjumped = false
	
	--self.x = self.x + self.hmom
	--self.y = self.y + self.vmom
	
	if true then --if not self.gost then --gost's block can't duck. you can use this to your advantage
		if self:keyDown("down") and self.verticaled == "down" and not self.ducking then
			self.ducking = true
			if not self.gost then
				self.height = 13
				self.y = self.y + 3
			end
		end
		if ((self.verticaled == "none") or (not self:keyDown("down"))) and self.ducking then
			if self.gost then self.ducking = false --when gost's block ducks, it doesn't actually change height, it just stops being able to move
			else
				--do we have space to unduck? this is emulated by pretending to give the player a vertical momentum of 3 pixels upward, at their current height, and then seeing if they would collide with anything.
				--subtly this means you can actually be ducking while in midair if you're being followed by something that gives you no room to unduck. @sylviefluff cute jump 4 mechanic
				local oldvmom = self.vmom
				self.vmom = -2.999 --if we use 3 here it will always be true if you duck in a one-tile-high corridor, since the collision scan uses >=/<= (or not </not >) somewhere instead of >/< for some reason. might have to do with when player is flush to the ground?
				local collisionresult = mobtools.doCollisionScan("vertical", self)
				if collisionresult == "none" then --if player did not collide with anything while simulating upward movement
					self.ducking = false
					self.height = 16
					self.y = self.y - 3
				end
				self.vmom = oldvmom
			end
		end
		if self:keyDown("up") and self.verticaled == "down" and self.hmom == 0 and not self.ducking then
		--if self:keyDown("up") and self.verticaled == "down" and not self.ducking and self:notWalkingLeft() and self:notWalkingRight() then --the former more closely matches behavior in jumper 3
			self.lookingup = true
		else
			self.lookingup = false
		end
	end
	
	self.x_clamped = math.floor(self.x + .5)
	self.y_clamped = math.floor(self.y + .5)
	
	--if math.abs(self.hmom) < 0.1 then
	if self.hmom == 0 then
		self.x = self.x_clamped
	end
	if self.vmom == 0 then
		self.y = self.y_clamped
	end
	
	if self.y > self.level.height and not (self.overlappingwin or juststoppedoverlappingwin) then self:die() end
end

function ogmo:keypressed(key)
	if key == controls["P" .. self.playerno .. "JUMP"] and self.alive and self.cutscenemovement ~= "down" and
		not ((self.cutscenemovement == "right" or self.cutscenemovement == "left") and self.cutscene_firstfreemovement)
	then self:jump()
	elseif key == controls["P" .. self.playerno .. "DIE"] and self.alive and not self.gost then self:die(false, true); audio.playsfxonce("ogmo die");
	elseif key == controls["P" .. self.playerno .. "INTERACT"] and self.alive then
		for _,obj in ipairs(self.overlaps) do
			if(obj.onInteract) then
				obj:onInteract(self)
			end
		end
	end
end

function ogmo:jump()
	local canwalljump = false
	if self.verticaled ~= "down" and self.walled ~= "none" then
		for _,thing in ipairs(self.walledby) do
			if not thing.notwalljumpable then
				canwalljump = true
			end
		end
	end
	if canwalljump then
		self.vmom = (self.vmom * self.jumpzaniness) - self.walljumpforce
		if self.walled == "left" then
			self.hmom = self.walljumpspeed
			self.tempfriction = self.walljumptempfriction
			self.tempfrictiontimer = self.walljumptempfrictionframes
		elseif self.walled == "right" then
			self.hmom = (-1 * self.walljumpspeed)
			self.tempfriction = self.walljumptempfriction
			self.tempfrictiontimer = self.walljumptempfrictionframes
		end
		if not self.gost then audio.playsfx("ogmo jump") end
		self.justjumped = true
	elseif self.jumps > 0 then
		self.tempfriction = nil --having temp friction stop when you jump feels more natural for some reason
		--self.tempfrictiontimer = 0 --for alternate behavior, uncomment this line and comment the above line. this makes it so when you jump you get the standard tempfriction phase-out as when your tempfriction from a walljump ends normally, rather than your friction immediately becoming normal. this *looks* nicer, but feels far less precise
		local jumpsound = "ogmo jump"
		self.vmom = (self.vmom * self.jumpzaniness) - self.jumpforce
		if self.skiddingtimer > 0 and self.verticaled == "down" then
			self.vmom = self.vmom - self.skidjumpextraforce
			--skidding cancels out all momentum in the direction you're skidding away from. in the original games i think skidding just killed all your horizontal momentum, period... but so did most things :p
			if self.skidding == "left" and self.hmom > 0 then self.hmom = 0
			elseif self.skidding == "right" and self.hmom < 0 then self.hmom = 0 end
			if self.skidding == "none" then print "how did you skidjump with no skidding state?" end
			jumpsound = "superjump"
		end
		self.jumps = self.jumps - 1
		if not self.gost then audio.playsfx(jumpsound) end
		self.justjumped = true
	end
	self.skiddingtimer = 0
	self.skidding = "none"
end

function ogmo:die(vanish, nosfx) --"vanish" arg is for if you are gost's block and you've been touched by an ogmo
	if self.alive and not self.level.frozen then
		if vanish then
			audio.playsfx("gostblock vanish")
			print("gost's block vanished")
		end
		if not self.gost and not nosfx then audio.playsfx("ogmo die") end
		self.alive = false
		self.solid = false
		local level = self.level
		if not self.gost then
			level.liveplayeramt = level.liveplayeramt - 1
			if level.liveplayeramt > 0 then print("ogmo is dead! players remaining: " .. level.liveplayeramt) end
		elseif not vanish then
			for i=1, #level.objects do
				obj = level.objects[i]
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
		local duckoffset = 0
		if self.currentquad == "duck" or self.currentquad == "duckblink" then duckoffset = -3 end
		if not self.gost then love.graphics.draw(graphics.load("ogmos/" .. game.ogmoskin), ogmo.quads[self.currentquad], self.x_clamped, self.y_clamped + duckoffset)
		else love.graphics.draw(graphics.load("ogmos/" .. game.ogmoskin), ogmo.quads["gost"], self.x_clamped, self.y_clamped) end
	end--[[
	love.graphics.print(booltostr(self.ducking), 400)
	love.graphics.print(booltostr(self.lookingup), 432)
	love.graphics.print(self.animtimer, 464)
	local r, g, b, a = love.graphics.getColor()
	love.graphics.setColor(0, 0, 0, a)
	love.graphics.rectangle("fill", 400, 0, 400, 16)
	love.graphics.setColor(r, g, b, a)
	love.graphics.print(self.x, 400)
	love.graphics.print(self.y, 416)
	--]]
	--if game.playeramt == 1 then love.graphics.print(self.tempfrictiontimer .. "", 400) end
end

return ogmo