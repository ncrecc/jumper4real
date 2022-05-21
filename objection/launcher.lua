launcher = class:new()

launcher.quads = {
	["normal_inactive"] =		quad(     0,   0,  16, 16, 160, 48),
	["normal_right"] =			quad(     0,   16, 16, 16, 160, 48),
	["normal_down"] =			quad(     16,  16, 16, 16, 160, 48),
	["normal_up"] =				quad(     0,   32, 16, 16, 160, 48),
	["normal_left"] =			quad(     16,  32, 16, 16, 160, 48),
	["normal_arrow_right"] =	quad(     16,  0,  8,  8,  160, 48),
	["normal_arrow_down"] =		quad(     24,  0,  8,  8,  160, 48),
	["normal_arrow_up"] =		quad(     16,  8,  8,  8,  160, 48),
	["normal_arrow_left"] =		quad(     24,  8,  8,  8,  160, 48),
	["fast_inactive"] =			quad(32 + 0,   0,  16, 16, 160, 48),
	["fast_right"] =			quad(32 + 0,   16, 16, 16, 160, 48),
	["fast_down"] =				quad(32 + 16,  16, 16, 16, 160, 48),
	["fast_up"] =				quad(32 + 0,   32, 16, 16, 160, 48),
	["fast_left"] =				quad(32 + 16,  32, 16, 16, 160, 48),
	["fast_arrow_right"] =		quad(32 + 16,  0,  8,  8,  160, 48),
	["fast_arrow_down"] =		quad(32 + 24,  0,  8,  8,  160, 48),
	["fast_arrow_up"] =			quad(32 + 16,  8,  8,  8,  160, 48),
	["fast_arrow_left"] =		quad(32 + 24,  8,  8,  8,  160, 48),
	["fragile_inactive"] =		quad(64 + 0,   0,  16, 16, 160, 48),
	["fragile_right"] =			quad(64 + 0,   16, 16, 16, 160, 48),
	["fragile_down"] =			quad(64 + 16,  16, 16, 16, 160, 48),
	["fragile_up"] =			quad(64 + 0,   32, 16, 16, 160, 48),
	["fragile_left"] =			quad(64 + 16,  32, 16, 16, 160, 48),
	["fragile_arrow_right"] =	quad(64 + 16,  0,  8,  8,  160, 48),
	["fragile_arrow_down"] =	quad(64 + 24,  0,  8,  8,  160, 48),
	["fragile_arrow_up"] =		quad(64 + 16,  8,  8,  8,  160, 48),
	["fragile_arrow_left"] =	quad(64 + 24,  8,  8,  8,  160, 48),
	["remote_inactive"] =		quad(96 + 0,   0,  16, 16, 160, 48),
	["remote_right"] =			quad(96 + 0,   16, 16, 16, 160, 48),
	["remote_down"] =			quad(96 + 16,  16, 16, 16, 160, 48),
	["remote_up"] =				quad(96 + 0,   32, 16, 16, 160, 48),
	["remote_left"] =			quad(96 + 16,  32, 16, 16, 160, 48),
	["remote_arrow_right"] =	quad(96 + 16,  0,  8,  8,  160, 48),
	["remote_arrow_down"] =		quad(96 + 24,  0,  8,  8,  160, 48),
	["remote_arrow_up"] =		quad(96 + 16,  8,  8,  8,  160, 48),
	["remote_arrow_left"] =		quad(96 + 24,  8,  8,  8,  160, 48),
	["twin_inactive"] =			quad(128 + 0,  0,  16, 16, 160, 48),
	["twin_right"] =			quad(128 + 0,  16, 16, 16, 160, 48),
	["twin_down"] =				quad(128 + 16, 16, 16, 16, 160, 48),
	["twin_up"] =				quad(128 + 16, 16, 16, 16, 160, 48),
	["twin_left"] =				quad(128 + 0,  16, 16, 16, 160, 48),
	["twin_arrow_right"] =		quad(128 + 16, 0,  8,  8,  160, 48),
	["twin_arrow_down"] =		quad(128 + 24, 0,  8,  8,  160, 48),
	["twin_arrow_up"] =			quad(128 + 16, 8,  8,  8,  160, 48),
	["twin_arrow_left"] =		quad(128 + 24, 8,  8,  8,  160, 48),
	["inert_inactive"] =		quad(144, 32, 16, 16, 160, 48)
}

function launcher.editordraw(x, y, options)
	local variant = options["variant"] or "normal"
	love.graphics.draw(graphics.load("launchers"), launcher.quads[variant .. "_inactive"], x, y)
end

function launcher:init(x, y, variant, delay, rotatedir)
	self.type = "launcher"
	self.variant = variant
	self.state = "inactive"
	self.drawlate = (self.variant ~= "remote" and self.variant ~= "inert")
	self.x = x
	self.y = y
	self.hmom = 0
	self.ymom = 0
	self.rotatedir = rotatedir
	self.width = tilesize
	self.height = tilesize
	self.solid = false
	self.broken = false
	self.rotatetimer = 0
	self.rotateframes = delay
	--self.rotateframes = delay or (function() if variant == "fast" then return 16 else return 32 end end)()
	self.launchspeed = 10
	self.minimumtakeoffspeed = 3 --if final launch speed ends up below this value (e.g. due to a remote pointing in the opposite direction) then the player doesn't enter careening state.
	self.content = false
	self.launchedcontent = false --refers to content that is currently being launched out of the launcher and has not exited the launcher's hitbox
	self.passive = true
end


function launcher:setup(x, y, options)
	if cheat.isactive("wrongway") then options["ccw"] = not options["ccw"] end
	
	local variant = options["variant"] or "normal"
	local rotatedir = 1
	local delay = 32
	
	if variant == "fast" then delay = 16 end
	
	if options["ccw"] then rotatedir = -1 end
	return launcher:new(x, y, variant, delay, rotatedir)
end

launcher.dirtable = {
	"up",
	"right",
	"down",
	"left",
	"up",
	"right",
}

launcher.dirtable__r = {
	right = 2,
	down = 3,
	left = 4,
	up = 5,
}

launcher.oppositedirs = {
	["right"] = "left",
	["down"]  = "up",
	["left"]  = "right",
	["up"]    = "down"
}

function launcher:deactivate()
	self.state = "inactive"
	self.rotatetimer = 0
	self.content.attachedtolauncher = 2 --in ogmo's script, attachedtolauncher counts down until it reaches 0, and then becomes false. this ends up meaning that you can't jump on the same update you get shot by a launcher. this is actually significant if you get launched without careening; e.g. launched by a remote, or "launched" by a launcher pointing in the opposite direction of an active remote. (if the launcher gets placed after ogmo in reading order, then there ends up being an extra update where ogmo can't jump, but that's trivial unless you try to jump on that frame by pausing, releasing s, then unpausing and pressing s on the same update.)
	if self.content.twin then self.content.twin.attachedtolauncher = 2 end
	self.content = false
end

function launcher:checkside(side, minimumspace)
	local collisionresult
	local axis = "vertical"
	minimumspace = minimumspace or 0.01
	
	if side == "left" or side == "right" then axis = "horizontal" end
	if side == "left" or side == "up" then minimumspace = minimumspace * -1 end
	
	self.solid = true
	self.content.solid = false
	if axis == "vertical" then
		local oldvmom = self.vmom
		self.vmom = minimumspace --check that moving a very miniscule amount will not result in a collision... though for twin launchers this "miniscule amount" becomes a bit bigger
		collisionresult = mobtools.doCollisionScan("vertical", self)
		self.vmom = oldvmom
	else
		local oldhmom = self.hmom
		self.hmom = minimumspace
		collisionresult = mobtools.doCollisionScan("horizontal", self)
		self.hmom = oldhmom
	end
	self.solid = false
	self.content.solid = true
	if collisionresult == "none" then return true else return false end
end

function launcher:update()
	if not self.broken then
		if self.state == "inactive" then
			if self.content then self.content = false end
			if self.rotatetimer > 0 then self.rotatetimer = 0 end
			
			local overlaps = mobtools.doOverlapScan(self, true)
			if not self.launchedcontent then
				for _,obj in ipairs(overlaps) do
					if(obj.type == "ogmo") and not (obj.gost) then
						if self.variant == "inert" then
							if not obj.careening and (math.abs(obj.hmom) >= self.minimumtakeoffspeed or math.abs(obj.vmom) >= self.minimumtakeoffspeed) then
								obj.careening = true
								if obj.grounded then obj.vmom = 0 end
								--if math.abs(obj.vmom) <= obj.gravity then obj.vmom = 0 end
							end
						else
							if self.variant ~= "remote" then
								obj.jumps = obj.defaultjumps - 1
								obj.x = self.x --note: if small players are added, x and y should be based on centering the object in the launcher
								obj.y = self.y
								obj.hmom = 0
								obj.vmom = 0
								obj.careening = true
							end
							obj.attachedtolauncher = true
							self.content = obj
							self.state = "right"
							self.rotatetimer = self.rotateframes
							audio.playsfx("launcher enter")
							break
						end
					end
				end
			else
				local contentfullylaunched = true
				for _,obj in ipairs(overlaps) do
					if obj == self.launchedcontent or obj == self.launchedcontent.twin then
						contentfullylaunched = false
						break
					end
				end
				if contentfullylaunched then
					self.launchedcontent.twin = false
					self.launchedcontent = false
				end
			end
		else
			if self.rotatetimer == 0 and self.state ~= "inactive" then
				self.state = launcher.dirtable[launcher.dirtable__r[self.state] + self.rotatedir]
				self.rotatetimer = self.rotateframes
				audio.playsfx("launcher tick")
			else self.rotatetimer = self.rotatetimer - 1 end
			
			if not self.content.alive then
				self.content = false
				self.state = "inactive"
				self.rotatetimer = 0
			end
		end
	end
end

function launcher:keypressed(key)
	if self.content and self.content.playerno then
		if key == controls["P" .. self.content.playerno .. "JUMP"] then
			local axis = "v"
			if self.state == "left" or self.state == "right" then axis = "h" end
			local sign = -1
			if self.state == "right" or self.state == "down" then sign = 1 end
			if self.variant == "twin" then
				if self:checkside(self.state, 8) and self:checkside(launcher.oppositedirs[self.state], 8) then
					local content = self.content
					local contentlevel = content.level
					local contentclone = ogmo:setup(content.x, content.y, {}, contentlevel)
					print("created content clone")
					content.twin = contentclone
					contentclone.level = contentlevel
					contentclone.careening = true
					contentclone.attachedtolauncher = true
					table.insert(contentlevel.objects, contentclone)
					if axis == "v" then
						content.y = content.y + (sign * 8)
						contentclone.y = contentclone.y - (sign * 8)
					else
						content.x = content.x + (sign * 8)
						contentclone.x = contentclone.x - (sign * 8)
					end
					contentlevel.liveplayeramt = contentlevel.liveplayeramt + 1
					contentclone.vmom = content.vmom
					contentclone.hmom = content.hmom
					content[axis .. "mom"] = content[axis .. "mom"] + (sign * self.launchspeed)
					if (content[axis .. "mom"] * sign) <= self.minimumtakeoffspeed then content.careening = false end
					contentclone[axis .. "mom"] = contentclone[axis .. "mom"] + ((-1 * sign) * self.launchspeed)
					if (contentclone[axis .. "mom"] * (-1 * sign)) <= self.minimumtakeoffspeed then contentclone.careening = false end
					
					--breaking it after use actually wasn't the original plan, it's just something i'm considering
					--self.broken = true
					--self.irrelevant = true
					
					audio.playsfx("launcher shoot")
					self.launchedcontent = self.content
					self:deactivate()
				end
			else
				if self:checkside(self.state) then
					self.content[axis .. "mom"] = self.content[axis .. "mom"] + (sign * self.launchspeed) --we don't set momentum directly so that remotes can synergize with normal launchers.
					--local minimumtakeoffspeed = self.content.maxspeed
					--if minimumtakeoffspeed > 10 then minimumtakeoffspeed = 10 end
					if (self.content[axis .. "mom"] * sign) <= self.minimumtakeoffspeed then self.content.careening = false end
					--if (self.content[axis .. "mom"] * sign) < minimumtakeoffspeed then self.content.careening = false end
					if self.variant == "remote" and axis == "h" then
						local frictiondivisor = self.launchspeed * 2
						if frictiondivisor < 1 then frictiondivisor = 1 end
						self.content.tempfriction = self.content.friction / (frictiondivisor)
						self.content.tempfrictiontimer = self.content.walljumptempfrictionframes --yeah it's not just used for walljumping anymore. which will result in a problem once there's a "climb up walls" powerup
						if self.content.twin then
							self.content.twin.tempfriction = self.content.twin.friction / (frictiondivisor)
							self.content.twin.tempfrictiontimer = self.content.twin.walljumptempfrictionframes
						end
					end
					if self.variant == "fragile" then
						self.broken = true
						self.irrelevant = true
					else
						self.launchedcontent = self.content
					end
					audio.playsfxonce("launcher shoot")
					self:deactivate()
				end
			end
		end
	end
end

function launcher:draw()
	if not self.broken then love.graphics.draw(graphics.load("launchers"), launcher.quads[self.variant .. "_" .. self.state], self.x, self.y) end
	if self.state ~= "inactive" then
		
	end
end

return launcher