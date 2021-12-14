button = class:new()

function button:init(x, y, id, image, action, onUpdate, tooltip)
	self.id = id
	self.image = image
	self.x = x
	self.y = y
	self.width = tilesize
	self.height = tilesize
	self.action = action
	self.onUpdate = onUpdate
	self.depressed = false
	self.tooltip = tooltip
end

function button:setup(x, y, id, image, action, onUpdate, tooltip)
	return button:new(x, y, id, image, action, onUpdate, tooltip)
end

function button:update()
	self.onUpdate(self) --avoiding syntactical sugar here because onUpdate is supplied as an arg so i don't really know how that would work
end

function button:draw()
	if not self.depressed then
		love.graphics.draw(graphics:load("ui/button"), self.x, self.y)
	else
		love.graphics.draw(graphics:load("ui/button_depressed"), self.x, self.y)
	end
	love.graphics.draw(graphics:load("ui/" .. self.image), self.x, self.y)
end

--return button