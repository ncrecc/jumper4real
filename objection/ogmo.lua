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
for i=0, 32 do --32 instead of 31. yes, we're starting at 0 and for loop syntax is inclusive in lua, so starting at 0 and iterating to 32 means we get 33 elements, but there is a 33rd element! gost's block, an object that acts like an additional ogmo and causes another ogmo to die when it dies
	--table.insert(ogmo.quads, love.graphics.newQuad((i % 4) * 16, math.floor(i / 4) * 16, 16, 16, 64, 160))
	ogmo.quads[ogmo.quaddefs[i + 1]] = love.graphics.newQuad((i % 4) * 16, math.floor(i / 4) * 16, 16, 16, 64, 160)
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
	self.player = true
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
	self.grounded = "none"
	self.walled = "none"
	self.extraverticalbits = {}
	self.extrahorizontalbits = {}
	self.justjumped = false
	
	self.gfxoffsets = {0, 0}
	
	--QUAD TIME
	self.currentquad = "idle"
	
	self.animtimer = 128
	self.animtimertoblink = 128
	self.animtimertounblink = 4
	self.animtimertostep = 4
	self.animtimertotumble = 3
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
	if self.alive then
		self:movement(dt)
		--major, game-breaking glitch in the following code: if you time your ducks or unducks frame perfectly, you can avoid blinking ever while idling/ducking, thus making you a monster depriving ogmo of sleep
		self.animtimer = self.animtimer - 1
		
		if self.vmom < 0 then
			if string.sub(self.currentquad, 1, 4) ~= "jump" then
				self.currentquad = "jump1"
				self.animtimer = self.animtimertotumble
			end
			jumpnum = tonumber(string.sub(self.currentquad, -1, -1))
			if not (love.keyboard.isDown("right") and love.keyboard.isDown("left")) then
				if love.keyboard.isDown("right") then self.currentquad = "jumpright" .. jumpnum
				elseif love.keyboard.isDown("left") then self.currentquad = "jumpleft" .. jumpnum end
			end
			if self.animtimer <= 0 and not(jumpnum == 1 and self.vmom > -0.5) then
				local jump = string.sub(self.currentquad, 1, -2)
				jumpnum = jumpnum + 1
				if jumpnum > 4 then jumpnum = 1 end
				self.currentquad = jump .. tostring(jumpnum)
				self.animtimer = self.animtimertotumble
			end
		elseif self.vmom > 0 then
			self.currentquad = "fall"
			if not (love.keyboard.isDown("right") and love.keyboard.isDown("left")) then
				if love.keyboard.isDown("right") then self.currentquad = "fallright"
				elseif love.keyboard.isDown("left") then self.currentquad = "fallleft" end
			end
		else
			if self.ducking and string.sub(self.currentquad, 1, 4) ~= "duck" then
				if string.sub(self.currentquad, 1, 4) ~= "idle" then self.animtimer = self.animtimertoblink end
				self.currentquad = "duck"
			end
			
			if not self.ducking and not (love.keyboard.isDown("right") and love.keyboard.isDown("left")) then
				if love.keyboard.isDown("right") and string.sub(self.currentquad, 1, -2) ~= "walkright" then
					self.currentquad = "walkright1"
					self.animtimer = self.animtimertostep
				elseif love.keyboard.isDown("left") and string.sub(self.currentquad, 1, -2) ~= "walkleft" then
					self.currentquad = "walkleft1"
					self.animtimer = self.animtimertostep
				end
			end
			
			if string.sub(self.currentquad, 1, 4) ~= "idle" and not self.ducking and ((love.keyboard.isDown("right") and love.keyboard.isDown("left")) or not (love.keyboard.isDown("right") or love.keyboard.isDown("left"))) then
				if string.sub(self.currentquad, 1, 4) ~= "duck" then self.animtimer = self.animtimertoblink end
				self.currentquad = "idle"
			end
			
			if self.animtimer <= 0 then
				if self.currentquad == "idle" then
					self.currentquad = "idleblink"
					self.animtimer = self.animtimertounblink
				elseif self.currentquad == "idleblink" then
					self.currentquad = "idle"
					self.animtimer = self.animtimertoblink
				elseif self.currentquad == "duck" then
					self.currentquad = "duckblink"
					self.animtimer = self.animtimertounblink
				elseif self.currentquad == "duckblink" then
					self.currentquad = "duck"
					self.animtimer = self.animtimertoblink
				elseif string.sub(self.currentquad, 1, -2) == "walkright" or string.sub(self.currentquad, 1, -2) == "walkleft" then
					local walk = string.sub(self.currentquad, 1, -2)
					local walknum = tonumber(string.sub(self.currentquad, -1, -1))
					walknum = walknum + 1
					if walknum > 4 then walknum = 1 end
					self.currentquad = walk .. tostring(walknum)
					self.animtimer = self.animtimertostep
				end
			end
		end
	end
end

function ogmo:notWalkingRight()
	if ((self.ducking) or
		(not love.keyboard.isDown("right")) or
		(love.keyboard.isDown("left") and love.keyboard.isDown("right")))
	then
		return true
	end
	return false
end

function ogmo:notWalkingLeft()
	if ((self.ducking) or
		(not love.keyboard.isDown("left")) or
		(love.keyboard.isDown("left") and love.keyboard.isDown("right")))
	then
		return true
	end
	return false
end

function ogmo:movement(dt)
	--can't remember precisely where but there's a lot of places here that negate maddy thorson's recurrent antipattern of counteracting the player moving against their current momentum but forgetting to apply the same hasrhness to the player not moving at all while they have momentum. this results in, among other things, neutraljumping being possible in celeste
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
	if not self.ducking and not (love.keyboard.isDown("right") and love.keyboard.isDown("left")) then
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
	
	if self:notWalkingRight() and self.hmom > 0 then
		if self.tempfriction ~= nil then
			self.hmom = self.hmom - self.tempfriction
		else
			self.hmom = self.hmom - self.friction
		end
		if self.hmom <= 0 then
			self.tempfriction = nil
			self.hmom = 0
		end
	elseif self:notWalkingLeft() and self.hmom < 0 then
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
	
	local applyhfirst = true
	if math.abs(self.vmom) > math.abs(self.hmom) then
		applyhfirst = false
	end
	
	local oldgroundedtemp = self.grounded
	
	local collisionfunctions = {
		horizontal = function()
			local newposition
			local colliders
			
			self.walled, newposition, colliders = mobtools.doCollisionScan("horizontal", self)
			local gostignorecollide = false
			if self.gost then
				gostignorecollide = true
				for k,collider in ipairs(colliders) do
					if collider.type ~= "ogmo" then
						gostignorecollide = false
						break
					end
				end
			end
			
			if newposition == nil or gostignorecollide then
				self.x = self.x + self.hmom
			else
				self.hmom = 0
				self.tempfriction = nil
				self.x = newposition
			end
		end,
		
		vertical = function()
			local newposition
			local colliders
			
			self.grounded, newposition, colliders = mobtools.doCollisionScan("vertical", self)
			local gostignorecollide = false
			if self.gost then
				gostignorecollide = true
				for k,collider in ipairs(colliders) do
					if collider.type ~= "ogmo" then
						gostignorecollide = false
						break
					end
				end
			end
			if newposition == nil or gostignorecollide then
				self.y = self.y + self.vmom
			else
				self.vmom = 0
				self.y = newposition
				if self.grounded == "down" then
					self.jumps = self.defaultjumps
					self.tempfriction = nil
				end
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
	
	local overlaps = mobtools.doOverlapScan(self)
	for k,v in ipairs(overlaps) do
		if(v.deathly) then
			self:die()
		elseif(v.type == "ogmo" and not v.gost and self.gost) then
			self:die(true)
		end
	end
	
	if self.justjumped == false and oldgroundedtemp == "down" and self.grounded == "none" then
		self.jumps = self.jumps - 1
	end
	
	self.justjumped = false
	
	--self.x = self.x + self.hmom
	--self.y = self.y + self.vmom
	
	if not self.gost then --gost's block can't duck. you can use this to your advantage
		if love.keyboard.isDown("down") and self.grounded == "down" and not self.ducking then
			self.ducking = true
			self.height = 13
			self.y = self.y + 3
		end
		if ((self.grounded == "none") or (not love.keyboard.isDown("down"))) and self.ducking then
			self.ducking = false
			self.height = 16
			self.y = self.y - 3
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
	
	if self.y > game.levelheight then self:die() end
end

function ogmo:keypressed(key)
	if key == "up" and self.alive then self:jump() end
end

function ogmo:jump()
	if self.grounded ~= "down" and self.walled ~= "none" then
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
		local duckoffset = 0
		if self.currentquad == "duck" or self.currentquad == "duckblink" then duckoffset = -3 end
		if not self.gost then love.graphics.draw(graphics:load("ogmos/" .. game.ogmoskin), ogmo.quads[self.currentquad], self.x_clamped, self.y_clamped + duckoffset)
		else love.graphics.draw(graphics:load("ogmos/" .. game.ogmoskin), ogmo.quads["gost"], self.x_clamped, self.y_clamped) end
	end
	--if game.playeramt == 1 then love.graphics.print(self.tempfrictiontimer .. "", 400) end
end

return ogmo