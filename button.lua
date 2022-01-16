button = class:new()

function button:init(x, y, id, image, quad, action, onUpdate, tooltip, onDraw)
	self.id = id
	self.image = image
	self.quad = quad
	self.x = x
	self.y = y
	self.width = tilesize
	self.height = tilesize
	self.action = action
	self.onUpdate = onUpdate
	self.depressed = false
	self.tooltip = tooltip
	self.iconrgba = {1, 1, 1, 1}
	self.onDraw = onDraw
end

function button:setup(x, y, id, image, quad, action, onUpdate, tooltip)
	return button:new(x, y, id, image, quad, action, onUpdate, tooltip)
end

function button:update()
	self.onUpdate(self) --avoiding syntactical sugar here because onUpdate is supplied as an arg so i don't really know how that would work
end

function button:draw()
	if self.onDraw then
		self.onDraw(self)
	else
		if not self.depressed then
			love.graphics.draw(graphics.load("ui/button"), self.x, self.y)
		else
			love.graphics.draw(graphics.load("ui/button_depressed"), self.x, self.y)
		end
		local r, g, b, a = love.graphics.getColor()
		love.graphics.setColor(self.iconrgba[1], self.iconrgba[2], self.iconrgba[3], self.iconrgba[4])
		if self.quad then
			love.graphics.draw(graphics.load("ui/" .. self.image), self.quad, self.x, self.y)
		else
			love.graphics.draw(graphics.load("ui/" .. self.image), self.x, self.y)
		end
		love.graphics.setColor(r, g, b, a)
	end
end

--return button