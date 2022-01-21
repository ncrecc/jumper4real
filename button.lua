button = class:new()

button.quads = {
	["normal"] = love.graphics.newQuad(0, 0, 16, 16, 32, 16),
	["depressed"] = love.graphics.newQuad(16, 0, 16, 16, 32, 16)
}

function button:init(x, y, id, image, imagequad, action, onUpdate, tooltip, onDraw)
	self.id = id
	self.image = image
	self.imagequad = imagequad
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

function button:setup(x, y, id, image, imagequad, action, onUpdate, tooltip)
	return button:new(x, y, id, image, imagequad, action, onUpdate, tooltip)
end

function button:update()
	self.onUpdate(self) --avoiding syntactical sugar here because onUpdate is supplied as an arg so i don't really know how that would work
end

function button:draw()
	if self.onDraw then
		self.onDraw(self) --i don't think this is going to be used at all?
	else
		local mystate = "normal"
		if self.depressed then mystate = "depressed" end
		love.graphics.draw(graphics.load("ui/editorbutton"), button.quads[mystate], self.x, self.y)
		local r, g, b, a = love.graphics.getColor()
		love.graphics.setColor(self.iconrgba[1], self.iconrgba[2], self.iconrgba[3], self.iconrgba[4])
		if self.imagequad then
			love.graphics.draw(graphics.load("ui/" .. self.image), self.imagequad, self.x, self.y)
		else
			love.graphics.draw(graphics.load("ui/" .. self.image), self.x, self.y)
		end
		love.graphics.setColor(r, g, b, a)
	end
end

--return button