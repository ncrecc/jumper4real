ashley = class:new()

function ashley:init(x, y, red, fast)
	self.type = "ashley"
	self.player = true
	self.playerno = 1
	self.x = x
	self.y = y
	self.x_clamped = x
	self.y_clamped = y
	self.red = red
	self.solid = true
	self.hmom = 0
	self.vmom = 0
	self.movetime = 0
	self.speed = 1 --pretty sure this should only be factors of 16
	self.height = tilesize
	self.width = tilesize
	if fast then self.speed = 2 end
	self.collisiondir = "none"
	self.alive = true
	self.grounded = true
end

function ashley:setup(x, y, options)
	local level = self.level
	level.playeramt = level.playeramt + 1
	red = false
	fast = false
	for i=1, #options do
		if options[i] == "red" then
			red = true
		elseif options[i] == "fast" then
			fast = true
		end
	end
	return ashley:new(x, y, red, fast)
end

function ashley:die() --rip
	local level = self.level
	self.alive = false
	self.solid = false
	audio.playsfx("ogmo die")
	level.liveplayeramt = level.liveplayeramt - 1
	if level.liveplayeramt > 0 then print("ashley is dead! players remaining: " .. level.liveplayeramt) end
end

function ashley:update()
	if self.alive then
		if self.hmom == 0 and self.vmom == 0 then self.movetime = 0 end
		if self.movetime <= 0 then self.hmom = 0; self.vmom = 0 end
		if love.keyboard.isDown("up") and self.movetime == 0 then
			self.movetime = 16 / self.speed
			self.vmom = -1 * self.speed
		elseif love.keyboard.isDown("down") and self.movetime == 0 then
			self.movetime = 16 / self.speed
			self.vmom = 1 * self.speed
		elseif love.keyboard.isDown("left") and self.movetime == 0 then
			self.movetime = 16 / self.speed
			self.hmom = -1 * self.speed
		elseif love.keyboard.isDown("right") and self.movetime == 0 then
			self.movetime = 16 / self.speed
			self.hmom = 1 * self.speed
		end
		if self.hmom ~= 0 then
			self.collisiondir, newposition = mobtools.doCollisionScan("horizontal", self)
			if newposition ~= nil then self.x = newposition; self.hmom = 0; self.movetime = 0; end
		end
		if self.vmom ~= 0 then
			self.collisiondir, newposition = mobtools.doCollisionScan("vertical", self)
			if newposition ~= nil then self.y = newposition; self.vmom = 0; self.movetime = 0; end
		end
		if self.movetime > 0 then
			self.x = self.x + self.hmom
			self.y = self.y + self.vmom
			self.movetime = self.movetime - 1
		end
		
		local overlaps = mobtools.doOverlapScan(self)
		for k,v in ipairs(overlaps) do
			if(v.deathly) then
				self:die()
				break
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
	end
end

function ashley:draw()
	if self.alive then
		mygraphic = "ashley"
		if self.red then mygraphic = "red_ashley" end
		love.graphics.draw(graphics.load(mygraphic), self.x_clamped, self.y_clamped)
	end
end

return ashley