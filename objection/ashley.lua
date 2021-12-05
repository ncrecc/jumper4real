ashley = class:new()

function ashley:init(x, y, red, fast)
	self.type = "ashley"
	self.x = x
	self.y = y
	self.red = red
	self.solid = true
	self.hmom = 0
	self.vmom = 0
	self.movetime = 0
	self.speed = 1 --pretty sure this should only be factors of 16
	self.height = tilesize
	self.width = tilesize
	if fast then self.speed = 2 end
end

function ashley:setup(x, y, options)
	playeramt = playeramt + 1
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

function ashley:die()
	self.alive = false
	self.solid = false
	liveplayeramt = liveplayeramt - 1
	if liveplayeramt > 0 then print("ashley is dead! players remaining: " .. liveplayeramt) end
end

function ashley:update()
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
	if self.movetime > 0 then
		self.x = self.x + self.hmom
		self.y = self.y + self.vmom
		self.movetime = self.movetime - 1
	end
end

function ashley:draw()
	mygraphic = "ashley"
	if self.red then mygraphic = "red_ashley" end
	love.graphics.draw(graphics:load(mygraphic), self.x, self.y)
end

return ashley